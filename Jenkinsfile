@Library('libpipelines@rundeck-nfs') _

hose {
    EMAIL = 'qa'
    DEVTIMEOUT = 20
    RELEASETIMEOUT = 20
    MODULE = 'marathon-lb'
    REPOSITORY = 'marathon-lb-sec'
    PKGMODULESNAMES = ['marathon-lb-sec']
    BUILDTOOL = 'make'
    NEW_VERSIONING = true
    GENERATE_QA_ISSUE = true
    INSTALLTIMEOUT = 20


    INSTALLSERVICES = []

    ATCREDENTIALS = [[TYPE:'sshKey', ID:'PEM_VMWARE']]

    INSTALLPARAMETERS = """
                    | -DDCOS_CLI_HOST=%%DCOSCLI#0
                    | -DREMOTE_USER=\$PEM_VMWARE_USER
                    | -DINSTALL_MARATHON=false
                    | """.stripMargin().stripIndent()
    }
                    
    DEV = { config ->
        doDocker(config)
    }

    INSTALL = { config, params ->
       def PARAMSMAP = stringToMap(params.ENVIRONMENT)

       if (config.INSTALLPARAMETERS.contains('GROUPS_MARATHONLB')) {
           config.INSTALLPARAMETERS = "${config.INSTALLPARAMETERS}".replaceAll('-DGROUPS_MARATHONLB', '-Dgroups')
	       if (params.ENVIRONMENT.contains('HETZNER_CLUSTER')) {

            def pempathhetzner = ""

            pempathhetzner = """${params.ENVIRONMENT}
                          |PEM_FILE_PATH=\$PEM_VMWARE_KEY
                          |""".stripMargin().stripIndent()

            def PATHHETZNER = stringToMap(pempathhetzner)
            def PATHHETZNERINSTALL = doReplaceTokens(INSTALLPARAMETERS.replaceAll(/\n/, ''), PATHHETZNER)  

          config.INSTALLSERVICES = [
            ['DCOSCLI':   ['image': 'stratio/dcos-cli:0.4.15-SNAPSHOT',
                            'volumes': [
                              '\$PEM_FILE_DIR:/tmp'
                            ],
                            'env':    ['DCOS_IP=\$DCOS_IP',
                                        'SSL=true',
                                        'SSH=true',
                                        'TOKEN_AUTHENTICATION=true',
                                        'DCOS_USER=\$DCOS_USER',
                                        'DCOS_PASSWORD=\$DCOS_PASSWORD',
                                        'CLI_BOOTSTRAP_USER=\$CLI_BOOTSTRAP_USER',
                                        'CLI_BOOTSTRAP_PASSWORD=\$CLI_BOOTSTRAP_PASSWORD'
                                      ],
                            'sleep':  120,
                            'healthcheck': 5000]]
            ]


	           doAT(conf: config, parameters: PATHHETZNERINSTALL, environmentAuth: PARAMSMAP['HETZNER_CLUSTER']) 
	       } else {

             def pempathvmware = ""

            pempathvmware = """${params.ENVIRONMENT}
                          |PEM_FILE_PATH=\$PEM_VMWARE_PATH
                          |""".stripMargin().stripIndent()

            def PATHVMWARE = stringToMap(pempathvmware)
            def PATHVMWAREINSTALL = doReplaceTokens(INSTALLPARAMETERS.replaceAll(/\n/, ''), PATHVMWARE) 

            config.INSTALLSERVICES = [
              ['DCOSCLI':   ['image': 'stratio/dcos-cli:0.4.15-SNAPSHOT',
                             'volumes': [
                               '\$PEM_FILE_DIR:/tmp'
                              ],
                              'env':     ['DCOS_IP=\$DCOS_IP',
                                          'SSL=true',
                                          'SSH=true',
                                          'TOKEN_AUTHENTICATION=true',
                                          'DCOS_USER=\$DCOS_USER',
                                          'DCOS_PASSWORD=\$DCOS_PASSWORD',
                                          'CLI_BOOTSTRAP_USER=\$CLI_BOOTSTRAP_USER',
                                          'PEM_PATH=/tmp/\${CLI_BOOTSTRAP_USER}_rsa'
                                         ],
                              'sleep':  120,
                              'healthcheck': 5000]]
              ]

	           doAT(conf: config, parameters: PATHVMWAREINSTALL)
	       }
       } else {
	       if (params.ENVIRONMENT.contains('HETZNER_CLUSTER')) {

            def pempathhetzner = ""

            pempathhetzner = """${params.ENVIRONMENT}
                          |PEM_FILE_PATH=\$PEM_VMWARE_KEY
                          |""".stripMargin().stripIndent()

            def PATHHETZNER = stringToMap(pempathhetzner)
            def PATHHETZNERINSTALL = doReplaceTokens(INSTALLPARAMETERS.replaceAll(/\n/, ''), PATHHETZNER)   

            config.INSTALLSERVICES = [
              ['DCOSCLI':   ['image': 'stratio/dcos-cli:0.4.15-SNAPSHOT',
                            'volumes': [
                              '\$PEM_FILE_DIR:/tmp'
                            ],
                            'env':    ['DCOS_IP=\$DCOS_IP',
                                        'SSL=true',
                                        'SSH=true',
                                        'TOKEN_AUTHENTICATION=true',
                                        'DCOS_USER=\$DCOS_USER',
                                        'DCOS_PASSWORD=\$DCOS_PASSWORD',
                                        'CLI_BOOTSTRAP_USER=\$CLI_BOOTSTRAP_USER',
                                        'CLI_BOOTSTRAP_PASSWORD=\$CLI_BOOTSTRAP_PASSWORD'
                                      ],
                            'sleep':  120,
                            'healthcheck': 5000]]
            ]

                   doAT(conf: config, groups: ['nightly'], parameters: PATHHETZNERINSTALL, environmentAuth: PARAMSMAP['HETZNER_CLUSTER'])   
        } else {

            def pempathvmware = ""

            pempathvmware = """${params.ENVIRONMENT}
                          |PEM_FILE_PATH=\$PEM_VMWARE_PATH
                          |""".stripMargin().stripIndent()

            def PATHVMWARE = stringToMap(pempathvmware)
            def PATHVMWAREINSTALL = doReplaceTokens(INSTALLPARAMETERS.replaceAll(/\n/, ''), PATHVMWARE)
            
              config.INSTALLSERVICES = [
                ['DCOSCLI':   ['image': 'stratio/dcos-cli:0.4.15-SNAPSHOT',
                             'volumes': [
                               '\$PEM_FILE_DIR:/tmp'
                              ],
                              'env':     ['DCOS_IP=\$DCOS_IP',
                                          'SSL=true',
                                          'SSH=true',
                                          'TOKEN_AUTHENTICATION=true',
                                          'DCOS_USER=\$DCOS_USER',
                                          'DCOS_PASSWORD=\$DCOS_PASSWORD',
                                          'CLI_BOOTSTRAP_USER=\$CLI_BOOTSTRAP_USER',
                                          'PEM_PATH=/tmp/\${CLI_BOOTSTRAP_USER}_rsa'
                                         ],
                              'sleep':  120,
                              'healthcheck': 5000]]
              ]

              doAT(conf: config, groups: ['nightly'], parameters: PATHVMWAREINSTALL)
	      } 
      }
    }
}
