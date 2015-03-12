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
            
            s.set('number_of_replicas ', 3);
            testCase.verifyEqual(s.get(' number_of_replicas'), 3);
            
            s.set('number_of_replicas', 3.0);
            testCase.verifyEqual(s.get(' number_of_replicas'), 3.0);
            
            s.set('number_of_replicas', 3.5);
            testCase.verifyError(@() s.set('number_of_replicas', 3.5),'SessionError:IntegerRequired')
          
        end
    end
    
end

