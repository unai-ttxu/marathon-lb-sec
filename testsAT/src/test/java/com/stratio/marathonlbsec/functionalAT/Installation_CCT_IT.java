package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/010_Installation/001_installationCCT_IT.feature"
},plugin = "json:target/cucumber.json")

public class Installation_CCT_IT extends BaseGTest {

    public Installation_CCT_IT() {
    }

    @Test(enabled = true, groups = {"installation_cct"}, dataProvider = "scenarios")
    public void AppWithSecurityES(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}