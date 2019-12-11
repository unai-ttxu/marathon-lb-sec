package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/010_Installation/002_checkDeployment_IT.feature"
},plugin = "json:target/cucumber.json")

public class Check_Deployment_IT extends BaseGTest {

    public Check_Deployment_IT() {
    }

    @Test(enabled = true, groups = {"check_deployment"}, dataProvider = "scenarios")
    public void checkDeployment(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}