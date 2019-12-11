package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = { "src/test/resources/features/functionalAT/030_Logs/02_QATM_2113_Log_Haproxy_Wrapper_Debug.feature" },plugin = "json:target/cucumber.json")
public class QATM_2113_Log_Haproxy_Wrapper_Debug_IT extends BaseGTest {

    public QATM_2113_Log_Haproxy_Wrapper_Debug_IT() {

    }

    @Test(enabled = true, groups = {"haproxyWrapperDebug"}, dataProvider = "scenarios")
    public void QATM1386_Certificates(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}
