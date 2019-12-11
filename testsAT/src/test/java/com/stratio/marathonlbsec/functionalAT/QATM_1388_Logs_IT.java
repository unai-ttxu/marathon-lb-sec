package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/030_Logs/01_MARATHONLB_1388_CentralizedLogs.feature",
},plugin = "json:target/cucumber.json")
public class QATM_1388_Logs_IT extends BaseGTest {

    public QATM_1388_Logs_IT() {
    }

    @Test(enabled = true, groups = {"centralizedlogs"}, dataProvider = "scenarios")
    public void QATM1388_Logs(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}
