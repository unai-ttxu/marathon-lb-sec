package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = { "src/test/resources/features/functionalAT/099_Uninstall/CCT_Uninstall_IT.feature" },plugin = "json:target/cucumber.json")
public class Uninstall_CCT_IT extends BaseGTest {

    public Uninstall_CCT_IT() {
    }

    @Test(enabled = true, groups = {"purge_cct"}, dataProvider = "scenarios")
    public void installation(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}
