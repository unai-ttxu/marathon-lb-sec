@Library('libpipelines@master') _

hose {
    EMAIL = 'qa'
    DEVTIMEOUT = 20
    RELEASETIMEOUT = 20
    PKGMODULESNAMES = ['marathon-lb-sec']
    BUILDTOOL = 'make'
    NEW_VERSIONING = 'true'
    INSTALLTIMEOUT = 20

    INSTALLSERVICES = [
            ['DCOSCLI':   ['image': 'stratio/dcos-cli:0.4.15-SNAPSHOT',
                           'env':     ['DCOS_IP=\$DCOS_IP',
                                       'SSL=true',
                                       'SSH=true',
                                       'TOKEN_AUTHENTICATION=true',
                                       'DCOS_USER=\$DCOS_USER',
                                       'DCOS_PASSWORD=\$DCOS_PASSWORD',
                                       'CLI_BOOTSTRAP_USER=\$CLI_BOOTSTRAP_USER',
                                       'CLI_BOOTSTRAP_PASSWORD=\$CLI_BOOSTRAP_PASSWORD'
                                      ],
                           'sleep':  120,
			                     'healthcheck': 5000]]
        ]

    ATCREDENTIALS = [[TYPE:'sshKey', ID:'PEM_VMWARE']]

    INSTALLPARAMETERS = """
                    | -DDCOS_CLI_HOST=%%DCOSCLI#0
                    | -DREMOTE_USER=\$PEM_VMWARE_USER
                    | -DPEM_FILE_PATH=\$PEM_VMWARE_KEY
                    | -DINSTALL_MARATHON=false
                    | """.stripMargin().stripIndent()
                    
    DEV = { config ->
        doDocker(config)
    }

    INSTALL = { config ->
       if (config.INSTALLPARAMETERS.contains('GROUPS_MARATHONLB')) {
           config.INSTALLPARAMETERS = "${config.INSTALLPARAMETERS}".replaceAll('-DGROUPS_MARATHONLB', '-Dgroups')
	       doAT(conf: config)
       } else {
           doAT(conf: config, groups: ['nightly'])
         }
     }

}
