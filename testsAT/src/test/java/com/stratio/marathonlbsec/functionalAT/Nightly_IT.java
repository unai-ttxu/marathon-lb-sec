package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberRunner;
import com.stratio.tests.utils.BaseTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/010_Installation/001_installationCCT_IT.feature",
        "src/test/resources/features/functionalAT/020_Certificates/01_MARATHONLB_1386_AppCertificate.feature",
        "src/test/resources/features/functionalAT/020_Certificates/02_MARATHONLB_1386_ClientCertificate.feature",
        "src/test/resources/features/functionalAT/020_Certificates/03_QATM_2113_Check_Invalid_AppCertificate.feature",
        "src/test/resources/features/functionalAT/020_Certificates/04_QATM_2113_Certificates_MarathonLB_Service.feature",
        "src/test/resources/features/functionalAT/030_Logs/01_MARATHONLB_1388_CentralizedLogs.feature",
        "src/test/resources/features/functionalAT/030_Logs/02_QATM_2113_Log_Haproxy_Wrapper_Debug.feature",
        "src/test/resources/features/functionalAT/030_Logs/03_QATM_2113_Vault_Renewal_Token.feature",
        "src/test/resources/features/functionalAT/050_check_haproxy_host_path/01_EOS_2920_check_multiple_deployments.feature"
}, plugin = "json:target/cucumber.json")
public class Nightly_IT extends BaseTest {

    public Nightly_IT() {
    }

    @Test(enabled = true, groups = {"nightly"})
    public void nightly() throws Exception {
        new CucumberRunner(this.getClass()).runCukes();
    }
}