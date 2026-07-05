/* msetup.cmd: a configure script for meson */
parse arg sBuildDir sArgs

call setenvvar 'LDFLAGS', '-Zhigh-mem'

sOpts =,
    '--prefix=/@unixroot/usr/local',
    '--default-library=static'

exit config( sBuildDir, sOpts, sArgs )

/**
 * Configure a build dir
 */
config: procedure expose E.
    parse arg sBuildDir, sOpts, sArgs

    /* Check parameters */
    if left( sBuildDir, 1 ) == '-' then
    do
        sArgs = strip( sBuildDir sArgs )
        sBuildDir = ''
    end
    sArgs = strip( sOpts sArgs )

    /* Check a build dir */
    if issrcdir( sBuildDir ) then
    do
        if sBuildDir \== '' then
        do
            say sBuildDir 'is a source directory!'

            return 1
        end

        /* default build dir */
        sBuildDir = 'build'
    end

    /* Find a top source dir */
    sCurDir = directory()
    sSrcDir = sCurDir
    do while \ issrcdir( sSrcDir )
        if length( sSrcDir ) < 4 then
        do
            /* Reached to a root directory */

            say 'Could not find a source directory!'

            /* Restore CWD */
            call directory sCurDir

            return 1
        end

        sSrcDir = directory( sSrcDir || '\..')
    end

    do while issrcdir( sSrcDir )
        sTopSrcDir = sSrcDir

        if length( sSrcDir ) < 4 then
        do
            /* Reached to a root directory */

            leave
        end

        sSrcDir = directory( sSrcDir || '\..')
    end

    /* Restore CWD */
    call directory sCurDir

    /* if --help, skip CD */
    if wordpos('--help', sArgs ) == 0 then
    do
        /* CD into a build dir */
        if directory( sBuildDir ) == '' then
        do
            'mkdir' sBuildDir '2>nul'
            if directory( sBuildDir ) == '' then
            do
                say 'Cannot change a directory to 'sBuildDir'!'

                return 1
            end
        end

        /* Copy the configure script file */
        parse source . . sMe
        'copy' sMe '1>nul 2>nul'
    end

    /* Add --reconfigure option if a build dir is already configured */
    if isbuilddir('.') then
        sArgs = sArgs '--reconfigure'

    call setlocal

    /* For the cases using Make while configuring */
    call value 'LANG', 'C', 'OS2ENVIRONMENT'
    call value 'MAKESHELL', 'sh.exe', 'OS2ENVIRONMENT'

    /* Pass env vars to OS/2 environment */
    call passenvvars

    /* Find the directory of meson.py */
    sMesonDir = value('MESON_DIR',, 'OS2ENVIRONMENT')
    if sMesonDir == '' then
        sMesonDir = 'f:/lang/work/meson/meson-os2.git'

    /* Launch meson */
    'python.exe' sMesonDir || '/meson.py setup' sTopSrcDir sArgs '2>&1 | tee msetup.log'
    ec = rc

    call endlocal

    return ec

/**
 * Check if the given build dir has been already configured
 */
isbuilddir: procedure
    parse arg sDir

    if sDir == '' then
        sDir = '.'

    return stream( strip( sDir, 'T', '\') || '\build.ninja', 'c', 'query exists') \== ''

/**
 * Check if the given dir is a source dir
 */
issrcdir: procedure
    parse arg sDir

    if sDir == '' then
        sDir = '.'

    return stream( strip( sDir, 'T', '\') || '\meson.build', 'c', 'query exists') \== ''

/**
 * Set an environment var
 */
setenvvar: procedure expose E.
    parse arg sKey, sVal

    if symbol('E.0') == 'LIT' then
        E.0 = 0

    E.0 = E.0 + 1
    i = E.0

    E.K.i = sKey
    E.V.i = sVal

    return

/**
 * Pass env vars to OS/2 environment
 */
passenvvars: procedure expose E.
    if symbol('E.0') == 'LIT' then
        return

    do i = 1 to E.0
        call value E.K.i, E.V.i, 'OS2ENVIRONMENT'
    end

    return
