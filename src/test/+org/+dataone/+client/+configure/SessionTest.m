classdef SessionTest < matlab.unittest.TestCase
    %TESTCONFIGURESESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties       
    end
    
    methods (TestMethodSetup)
        
        function setUp(testCase)
            % SETUP Set up the test environment
        
        end
    end
    
    methods (TestMethodTeardown)
        
        function tearDown(testCase)
            % TEARDOWN Tear down the test environment
            
        end
    end
    
    methods (Test)
        function testSetGet(testCase)
            import org.dataone.client.configure.Session;
           
            s = Session();
            s.set('certificate_path', '/tmp');
            testCase.verifyEqual(s.get('certificate_path'), '/tmp');
            
           % s.set('member_node_base_url', testCase.MN_base_url);
           % testCase.verifyEqual(s.get('member_node_base_url'), testCase.MN_base_url);
           % s.set('member_node_base_url', testCase.MN_invalid_base_url);
           % testCase.verifyError(s.get('member_node_base_url'),'MalformedURLException');
        end
    end
    
end

