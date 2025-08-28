set shell := ['powershell.exe', '-c']

r9x_toolchain := 'rust9x'
r9x_target := 'i686-rust9x-windows-msvc'
r9x_editbin := 'C:\vc2010-tools\editbin.exe'

# These settings shoud work for Windows XP
subsystem := 'CONSOLE,5.0'
os_version := '3.1'

build *FLAGS: (do-build 'debug' FLAGS)
release *FLAGS: (do-build 'release' '--release' FLAGS)
do-build PROFILE *FLAGS='': (r9x 'build' '--target' r9x_target FLAGS) (editbin 'target\'+r9x_target+'\'+PROFILE+'\rosu_pp_ffi.dll')
run *FLAGS: (r9x 'run' '--target' r9x_target FLAGS)

r9x $COMMAND *FLAGS:
    cargo +{{ r9x_toolchain }} {{ COMMAND }} {{ FLAGS }}

# PE executables specify the subsystem and subsystem version as well as the required OS version.
#
# `link.exe` has the same switches, but doesn't allow setting them to values that lie outside of the
# supported range of the toolset. `editbin.exe` is a bit more forgiving, only warning about
# "invalid" values (`LINK : warning LNK4241: invalid subsystem version number 4`), but still
# carrying out the change as requested. `/OSVERSION` is entirely undocumented, but still works,
# setting the minimum required OS version. Both values must be in a supported range for the target
# OS to accept and run the executable.
editbin EXECUTABLE:
    & "{{ r9x_editbin }}" {{ EXECUTABLE }} /SUBSYSTEM:{{ subsystem }} /OSVERSION:{{ os_version }} /RELEASE /STACK:1048576
