package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/020_Certificates/QATM_1685_Invalid_Certificates_IT.feature"
},plugin = "json:target/cucumber.json")
public class QATM_1685_Invalid_Certificates_IT extends BaseGTest {

    public QATM_1685_Invalid_Certificates_IT() {
    }

    @Test(enabled = true, groups = {"invalid_certificates"}, dataProvider = "scenarios")
    public void QATM_1685_Invalid_Certificates_IT(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}