@isTest
private class TMN_TreePktDocTableTest {
    
    private static TMN_TreePktDocTable treeTable;
    
    static void createData() {
        treeTable = new TMN_TreePktDocTable();
        treeTable.root.children.add(new TMN_TreePktDocTable.node('1','One'));
        treeTable.root.children.add(new TMN_TreePktDocTable.node('2','Two'));
        treeTable.root.children.add(new TMN_TreePktDocTable.node('3','Three'));
        treeTable.root.children.add(new TMN_TreePktDocTable.node('4','Four'));
        treeTable.root.children.add(new TMN_TreePktDocTable.node('5','Five'));

        treeTable.root.children.get(0).children.add(new TMN_TreePktDocTable.node('11',' '));
        treeTable.root.children.get(0).children.add(new TMN_TreePktDocTable.node('12',' '));
        treeTable.root.children.get(0).children.add(new TMN_TreePktDocTable.node('13',' '));
        treeTable.root.children.get(0).children.add(new TMN_TreePktDocTable.node('14',' '));
        
        treeTable.root.children.get(1).children.add(new TMN_TreePktDocTable.node('21',' '));
        treeTable.root.children.get(1).children.add(new TMN_TreePktDocTable.node('22',' '));
        treeTable.root.children.get(1).children.add(new TMN_TreePktDocTable.node('23',' '));
        
        treeTable.root.children.get(2).children.add(new TMN_TreePktDocTable.node('31',' '));
        treeTable.root.children.get(2).children.add(new TMN_TreePktDocTable.node('32',' '));
        treeTable.root.children.get(2).children.add(new TMN_TreePktDocTable.node('33',' '));

        treeTable.root.children.get(3).children.add(new TMN_TreePktDocTable.node('41',' '));
        treeTable.root.children.get(3).children.add(new TMN_TreePktDocTable.node('42',' '));
        treeTable.root.children.get(3).children.add(new TMN_TreePktDocTable.node('43',' '));

        treeTable.root.children.get(4).children.add(new TMN_TreePktDocTable.node('51',' '));
        treeTable.root.children.get(4).children.add(new TMN_TreePktDocTable.node('52',' '));
        treeTable.root.children.get(4).children.add(new TMN_TreePktDocTable.node('53',' '));
    }

 
    static testMethod void testNodeKeyMap() {
    	createData();
        system.assertNotEquals(null, TMN_TreePktDocTable.buildNodeKeyMapFor(treeTable.root.children).get('43'));
        system.assertEquals(null, TMN_TreePktDocTable.buildNodeKeyMapFor(treeTable.root.children).get('54'));
    }

    static testMethod void testSelectedKey() {
    	createData();
    	map<string, TMN_TreePktDocTable.node> nodeKeyMap = TMN_TreePktDocTable.buildNodeKeyMapFor(treeTable.root.children);
    	
    	List<String> selectedStr = new List<String>();
    	selectedStr.add('32');
    	selectedStr.add('51');
    	
    	treeTable.inputSelectedKeys(selectedStr, true);    	
    	
    	system.assertEquals(true,nodeKeyMap.get('32').Selected);
    	system.assertEquals(true,nodeKeyMap.get('51').Selected);
    	system.assertEquals(false,nodeKeyMap.get('52').Selected);
    	
    	system.assertEquals(String.valueOf(selectedStr).remove(' '),'('+treeTable.GetSelectedNodeStr+')');
    	
    }
 
    
    

}