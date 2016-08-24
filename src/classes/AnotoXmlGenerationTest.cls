/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AnotoXmlGenerationTest {

    static testMethod void WidgetElementGeneration() {
        AnotoXmlGeneration.Widget widget = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.boxed, 'firat');
        widget.Layout(1,10.0, 11.0, 12.0, 13.0);
        Dom.Document doc = new Dom.Document();
        dom.Xmlnode root = doc.createRootElement('root', '', 'test');
        
        widget.GenerateLayout(root);
        
        Dom.Xmlnode testnode = root.getChildren()[0];
        
        System.Assert(testnode != null);
        System.assertEquals('Widget', testnode.getName());
        System.assertEquals(null, testnode.getNamespace());
        System.assertEquals(1, Decimal.valueOf(testnode.getAttribute('page', '')));
        System.assertEquals(33.333, Decimal.valueOf(testnode.getAttribute('top', '')));
        System.assertEquals(36.667, Decimal.valueOf(testnode.getAttribute('left', '')));
    }

    static testMethod void ValueElementGeneration0() {
        AnotoXmlGeneration.Widget widget = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.boxed, 'first');
        
		Dom.Document doc = new Dom.Document();
        dom.Xmlnode root = doc.createRootElement('root', '', 'test');
        
        widget.GeneratePrepopulateValue(root);
        
        System.assertequals(0,  root.getChildren().size());
    }

    static testMethod void ValueElementGeneration1() {
        AnotoXmlGeneration.Widget widget = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.boxed, 'first');
        widget.DefaultValue = 'test value';
        Dom.Document doc = new Dom.Document();
        dom.Xmlnode root = doc.createRootElement('root', '', 'test');
        
        widget.GeneratePrepopulateValue(root);
        
        Dom.Xmlnode[] testnodes = root.getChildren();
        
        System.Assertequals(1, testnodes.size());
        System.assertEquals('first', testnodes[0].getName());
        System.assertEquals('test value', testnodes[0].getText());
    }
}