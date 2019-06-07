package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberRunner;
import com.stratio.tests.utils.BaseTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/020_Certificates/03_QATM_2113_Check_Invalid_AppCertificate.feature",
},plugin = "json:target/cucumber.json")
public class QATM_2113_CheckInvalidAppCertificates_IT extends BaseTest {

    public QATM_2113_CheckInvalidAppCertificates_IT() {

    }

    @Test(enabled = true, groups = {"checkInvalidAppCerts"})
    public void nightly() throws Exception {
        new CucumberRunner(this.getClass()).runCukes();
    }
}
