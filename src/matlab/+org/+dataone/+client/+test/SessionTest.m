classdef SessionTest < matlab.unittest.TestCase
    %TESTCONFIGURESESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       
    end
    
    methods (Test)
        function testFunction(testCase)
            import org.dataone.client.configure.Session;
           
            s = Session();
            s.x509CertificatePath = '/tmp';
            testCase.verifyEqual(s.x509CertificatePath, 'test/tmp');
        end
    end
    
end

