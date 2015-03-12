classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture( ...
        fullfile('matlab'))}) ...
    SessionTest < matlab.unittest.TestCase
    %TESTCONFIGURESESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       MN_base_url = 'https://mn-demo-1.test.dataone.org/metacat/d1/mn';
       MN_invalid_base_url = 'ftp://mn-demo-1.test.dataone.org/metacat/d1/mn';
    end
    
    methods (Test)
        function testSetGet(testCase)
            import org.dataone.client.configure.Session;
           
            s = Session();
            s.set('certificate_path', '/tmp');
            testCase.verifyEqual(s.get('certificate_path'), '/tmp');
            
            s.set('member_node_base_url', testCase.MN_base_url);
            testCase.verifyEqual(s.get('member_node_base_url'), testCase.MN_base_url);
            s.set('member_node_base_url', testCase.MN_invalid_base_url);
            testCase.verifyFail(s.get('member_node_base_url'));
        end
    end
    
end

