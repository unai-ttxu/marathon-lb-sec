package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/020_Certificates/QATM_1685_Invalid_Password.feature"
},plugin = "json:target/cucumber.json")
public class QATM_1685_Invalid_Password_IT extends BaseGTest {

    public QATM_1685_Invalid_Password_IT() {
    }

    @Test(enabled = true, groups = {"invalid_password"}, dataProvider = "scenarios")
    public void QATM_1685_Invalid_Password(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}