package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/020_Certificates/03_QATM_2113_Check_Invalid_AppCertificate.feature",
},plugin = "json:target/cucumber.json")
public class QATM_2113_CheckInvalidAppCertificates_IT extends BaseGTest {

    public QATM_2113_CheckInvalidAppCertificates_IT() {

    }

    @Test(enabled = true, groups = {"checkInvalidAppCerts"}, dataProvider = "scenarios")
    public void nightly(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}
