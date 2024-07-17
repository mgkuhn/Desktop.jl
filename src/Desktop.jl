"""
Basic GUI desktop interactions, such as opening a URL with
a web browser.

# Example:
```julia
using Desktop
if hasdesktop()
   browse_url("https://julialang.org/")
else
   @info("No desktop environment available")
end
```
"""
module Desktop

export hasdesktop, browse_url, open_file

using Base.Filesystem

# some standard Win32 API types and constants, see [MS-DTYP]
const BOOL = Cint
const DWORD = Culong
const LPDWORD = Ref{DWORD}
const HWINSTA = Ptr{Cvoid}
const UOI_NAME = 2

# auxiliary function for the Windows part of hasdesktop()
"""
    windows_station_name()

    Query the name of the “windows station” in which the current
    Win32 process is running. If this is `WinSta0`, the process
    has access to a GUI desktop.
"""
function windows_station_name()
    hwinsta = ccall((:GetProcessWindowStation, "user32.dll"),
                    stdcall, HWINSTA, ())
    Base.windowserror("GetProcessWindowStation", hwinsta == C_NULL)
    buf = zeros(UInt8, 80)
    len = LPDWORD(0)
    r = ccall((:GetUserObjectInformationA, "user32.dll"), stdcall, BOOL,
              (Ptr{Cvoid}, Cint, Ptr{Cvoid}, DWORD, LPDWORD),
              hwinsta, UOI_NAME, buf, sizeof(buf), len)
    Base.windowserror("GetUserObjectInformationA", r == 0)
    buf[end] = 0
    return unsafe_string(pointer(buf))
end

"""
    hasdesktop()

Returns `true` if the current process appears to have access to a
graphical desktop environment and is therefore likely to succeed when
invoking GUI functions or applications.

The algorithm used is a platform-dependent heuristic:

- On Microsoft Windows: tests if the current process is running in a
  “windows station” called `WinSta0`

- On macOS: checks the has-graphic-access bit in the security session
  information of the calling process

- On other platforms: checks if a non-empty environment variable
  `DISPLAY` or `WAYLAND_DISPLAY` exists

It only checks the native GUI interface of the respective platform;
e.g. an available X11 server will be ignored on Windows or macOS.
"""
function hasdesktop()
    if Sys.iswindows()
        return windows_station_name() == "WinSta0"
    elseif Sys.isapple()
        # https://developer.apple.com/documentation/security/1593382-sessiongetinfo
        callerSecuritySession = 0xffffffff
        sessionHasGraphicAccess = 16
        errSessionSuccess = 0
        attrs = Ref{Cuint}(0)
        r = ccall(:SessionGetInfo,
                  Cint, (Cuint, Ref{Cuint}, Ref{Cuint}),
	          callerSecuritySession, C_NULL, attrs)
        if r == errSessionSuccess
	  return (attrs[] & sessionHasGraphicAccess) != 0
        else
	  @error r
        end
    else
        return (!isempty(get(ENV, "DISPLAY", "")) ||
                !isempty(get(ENV, "WAYLAND_DISPLAY", "")))
    end
end


"""
    browse_url(url::AbstractString)

Attempts to launch a web browser to display the document available at
the provided URL or filesystem path.

The success of this function depends on access to a GUI desktop
environment.

See also: [`hasdesktop`](@ref), [`open_file`](@ref)
"""
function browse_url(url::AbstractString)
    if Sys.iswindows()
        # https://github.com/LOLBAS-Project/LOLBAS/blob/master/Archive-Old-Version/OSLibraries/Url.dll.md
        return success(`rundll32.exe url.dll,OpenURL $url`)
    elseif Sys.isapple()
    	# currently requests Safari explicitly, as e.g. Google Chrome
	# (if that's the default browser) fails to open the
	# Julia documentation index.html due to that file
	# commonly being installed with xattr com.apple.quarantine
        # https://github.com/JuliaLang/julia/issues/34275
        return success(`/usr/bin/open -a safari $url`)
    else
        for browser in [
            "/usr/bin/xdg-open",
            "/usr/bin/firefox",
            "/usr/bin/google-chrome",
        ]
            if isfile(browser)
                return success(`$browser $url`)
            end
        end
        @error "Cannot find a web browser to display $url"
    end
end


"""
    open_file(path::AbstractString)

Opens a file using a default application that the operating system
or desktop environment associates with this file type.

The success of this function may depend on access to a GUI desktop
environment.

See also: [`hasdesktop`](@ref), [`browse_url`](@ref)
"""
function open_file(path::AbstractString)
    if Sys.iswindows()
        # https://github.com/LOLBAS-Project/LOLBAS/blob/master/Archive-Old-Version/OSLibraries/Url.dll.md
        return success(`rundll32.exe url.dll,FileProtocolHandler $path`)
    elseif Sys.isapple()
        return success(`/usr/bin/open $path`)
    else
        for handler in [
            "/usr/bin/xdg-open",
            "/usr/bin/run-mailcap",
        ]
            if isfile(handler)
                return success(`$handler $path`)
            end
        end
        @error "Cannot find an application to open $path"
    end
end


# TODO: Should Julia have more functions for basic desktop interaction
# (open, print, edit a file), like an equivalent of
# https://docs.oracle.com/javase/9/docs/api/java/awt/Desktop.html
# as a Base.Desktop module?
# See also similar packages:
# http://www.davidc.net/programming/java/browsing-urls-and-opening-files
# https://github.com/GiovineItalia/Gadfly.jl/blob/master/src/open_file.jl

end # module
