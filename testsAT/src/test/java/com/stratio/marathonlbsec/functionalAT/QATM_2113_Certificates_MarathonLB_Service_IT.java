package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/020_Certificates/04_QATM_2113_Certificates_MarathonLB_Service.feature"
},plugin = "json:target/cucumber.json")
public class QATM_2113_Certificates_MarathonLB_Service_IT extends BaseGTest {

    public QATM_2113_Certificates_MarathonLB_Service_IT() {

    }

    @Test(enabled = true, groups = {"certsMarathonLBServ"}, dataProvider = "scenarios")
    public void nightly(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}
