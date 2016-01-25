% SessionTEST A class used to test the org.dataone.client.v2.Session class functionality
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2015 DataONE
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

classdef SessionTest < matlab.unittest.TestCase
    
    properties
    end

    methods (Test)
        
        function testInstantiate(testCase)
            % TESTINSTANTIATE tests instantiation of the object
            
            import org.dataone.client.v2.Session;
            import org.dataone.client.v2.Session;
            session = Session();
            
            testCase.assertInstanceOf(session, 'org.dataone.client.v2.Session');
            
        end
        
        function testTokenSession(testCase)
            % TESTTOKENSESSION tests a JWT token-based sesssion
            
            import org.dataone.client.configure.Configuration;
            import org.dataone.client.v2.Session;
            config = Configuration.loadConfig('');
            
            saved_authentication_token = config.authentication_token;
            saved_certificate_path = config.certificate_path;
            
            % Use a known expired token
            set(config, 'authentication_token', ...
                ['eyJhbGciOiJSUzI1NiJ9.eyJleHAiOjE0NTM0NzI' ...
                'yMTgsInN1YiI6IkNOPUNocmlzdG9waGVyIEpvbmV' ...
                'zIEEyMTA4LE89R29vZ2xlLEM9VVMsREM9Y2lsb2d' ...
                'vbixEQz1vcmciLCJjb25zdW1lcktleSI6InRoZWN' ...
                'vbnN1bWVya2V5IiwiaXNzdWVkQXQiOiIyMDE2LTA' ...
                'xLTIxVDIwOjE2OjU4Ljc0NSswMDowMCIsInVzZXJ' ...
                'JZCI6IkNOPUNocmlzdG9waGVyIEpvbmVzIEEyMTA' ...
                '4LE89R29vZ2xlLEM9VVMsREM9Y2lsb2dvbixEQz1' ...
                'vcmciLCJmdWxsTmFtZSI6bnVsbCwidHRsIjo2NDg' ...
                'wMCwiaWF0IjoxNDUzNDA3NDE4fQ.Pw7aazGfkeDu' ...
                '7I0cc5_IY_PW-RKf-fgo6SQP3uMrlRJRn1XQiRdl' ...
                'jxQqNm68AwrC99a5n3sQo38HuQkcscTR1F2TI6pK' ...
                'ahHco7EbDtk_PhEGLH--0KiKVnix8X_EglCeIChv' ...
                'sRpYRr0ky2nAw35K_eFndYz7nEFvoE8w_rdhXX_4' ...
                'u5byhouA6YGohvhb6wwFPWtUOqwIfOzcglaYfy25' ...
                'pLu9BfdCL1OCQeQD7pWqxk7xHAa9ZC0vvl1sLQ45' ...
                'C_OLuYbkRi3yACG9I-xoLWBzeWeK68cOtWBa40g5' ...
                'EaBPyPin5n7itrjhBo9YTPRhgJod0Zyubds8HNl0' ...
                'Vb1-WtXCE2H4RfiJB5x8uWnE9TYiEGTYENdrL4lV' ...
                'ixeblhet_KIgGM0RAQFfHJ-RE6PPYdhr0O8DD1ry' ...
                'nfOR_KU-cmscsSp-d93bh88sndeld9G81Rr0KudI' ...
                'MrMlxDn1D8p9Gj07Nq5_Is6cjOtsAWNX0XB1_xZ-' ...
                '8_kaX49AU26R-n7FcTImz6beTXRWzZjS_zAVj4t4' ...
                'DGV-WDe1aOb4ssczHMqSnuYvQUDs2uqeoCLGH64A' ...
                'Q4gHaZ6y47n0IAAzXSnReF_ZYPMUr4KcpB9AoigJ' ...
                '3t1EorwhH3zg7MZMgGIrTwr3y0e0G4Jm8eUxDLl3' ...
                '8Y3Haxwilzm0f31qcTzM8uRAFTT3Pmo']);            
            set(config, 'certificate_path', '');
            
            % Get a session
            session = Session();
            
            known_subject = 'CN=Christopher Jones A2108,O=Google,C=US,DC=cilogon,DC=org';
            known_expire_datenum = datenum( ...
                datetime('2016-01-22 14:16:58.000000000+0000', ...
                'TimeZone', 'UTC', ...
                'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSSSSSZ', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSSSSSZ'));
            actual_expire_datenum = datenum( ...
                datetime(session.expiration_date, ...
                'ConvertFrom', 'datetime', ...
                'TimeZone', 'UTC', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSSSSSZ'));
            known_type = 'authentication token';
            known_status = 'expired';
            
            assertEqual(testCase, known_subject, session.account_subject);
            assertEqual(testCase, known_expire_datenum, actual_expire_datenum);
            assertEqual(testCase, known_type, session.type);
            assertEqual(testCase, known_status, session.status);
            
            % Reset the token if it was set beforehand
            set(config, 'authentication_token', saved_authentication_token);
            set(config, 'certificate_path', saved_certificate_path);
                
        end
        
        function testCertificateSession(testCase)
            % TESTCERTIFICATESESSION tests an X509 certificate-based session
            
            import org.dataone.client.configure.Configuration;
            import org.dataone.client.v2.Session;
            config = Configuration.loadConfig('');
            saved_authentication_token = config.authentication_token;
            saved_certificate_path = config.certificate_path;
            
            % Use a known expired X509 certificate
            pem_text = [ ...
            '-----BEGIN CERTIFICATE-----', ...
            char(10), ...
            'MIIEBTCCAu2gAwIBAgIDAiZ5MA0GCSqGSIb3DQEBCwUAMGsxEzARBgoJkiaJk/Is', ...
            char(10), ...
            'ZAEZFgNvcmcxFzAVBgoJkiaJk/IsZAEZFgdjaWxvZ29uMQswCQYDVQQGEwJVUzEQ', ...
            char(10), ...
            'MA4GA1UEChMHQ0lMb2dvbjEcMBoGA1UEAxMTQ0lMb2dvbiBPcGVuSUQgQ0EgMTAe', ...
            char(10), ...
            'Fw0xNTEyMDQxODI3MDdaFw0xNTEyMDUxMjMyMDdaMG4xEzARBgoJkiaJk/IsZAEZ', ...
            char(10), ...
            'FgNvcmcxFzAVBgoJkiaJk/IsZAEZFgdjaWxvZ29uMQswCQYDVQQGEwJVUzEPMA0G', ...
            char(10), ...
            'A1UEChMGR29vZ2xlMSAwHgYDVQQDExdDaHJpc3RvcGhlciBKb25lcyBBMjEwODCC', ...
            char(10), ...
            'ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIB8V7iprvUDOGV3qTV3uPVb', ...
            char(10), ...
            '81V1kEXlXah2VSKAYqyto84rpU5Ov9KbjLjhNHrrBQuQN9izfH/h2FV+H6YilXl2', ...
            char(10), ...
            'FtBSzkDn9XgRdxMzos8qomsxAhK1MJaINEQYzQZn6IYa5sufE9ajLDHfB8wOAcFQ', ...
            char(10), ...
            'lXJ3RT4mxQ5vvHJKRtb5jZ9H9CnmuzbG9cGWSL7SpFMtYsCcLGALb3TO3vlAu3OQ', ...
            char(10), ...
            '4yeb/7MbvsjiaLDoNeUHCs7xwBZiuJMZOIOzuLXaYujPY/gAWwnS7AgPIDoX5Y/f', ...
            char(10), ...
            'juVkhLK/Hig2x0a0OgYa+LsyCvGYnacllxXzHQLi59d/jGiN/CtmnYqHHBEoD8MC', ...
            char(10), ...
            'AwEAAaOBrjCBqzAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIEsDATBgNVHSUE', ...
            char(10), ...
            'DDAKBggrBgEFBQcDAjAYBgNVHSAEETAPMA0GCysGAQQBgpE2AQMEMDoGA1UdHwQz', ...
            char(10), ...
            'MDEwL6AtoCuGKWh0dHA6Ly9jcmwuY2lsb2dvbi5vcmcvY2lsb2dvbi1vcGVuaWQu', ...
            char(10), ...
            'Y3JsMCAGA1UdEQQZMBeBFWNqb25lc0BuY2Vhcy51Y3NiLmVkdTANBgkqhkiG9w0B', ...
            char(10), ...
            'AQsFAAOCAQEAoOYnLH/hVCMrAV8eycLtth8ELZByKitvQQ6NwSk5vRHhxYwvvin7', ...
            char(10), ...
            '4R5kEec6afAFElSycQn1YoYUW98K4mwlC/JwJWIDkLPsseJsqBbazg8G1vSfB2ta', ...
            char(10), ...
            'UAN3KHQuOuvYa8ChXELuy4rUOg3pcs8gNGSiPaK8f479mvuMp/VLUg0rkJb9ud8X', ...
            char(10), ...
            'N3HXmZiEfqIk2CVp5irrwrKZq0Ank8kspq3J+aDkxso7wm7jE5cWgOs54aMGYVxl', ...
            char(10), ...
            'CEUMO1endtvXDWhvda/CILcD/ZZuOjSv1ecoP2W/rZi4C3GCtx++B3HyuRycISaJ', ...
            char(10), ...
            '8nAP+WDY62BcLh3tOyy+mfmvfbo92qk9BQ==', ...
            char(10), ...
            '-----END CERTIFICATE-----', ...
            char(10), ...
            '-----BEGIN RSA PRIVATE KEY-----', ...
            char(10), ...
            'MIIEogIBAAKCAQEAgHxXuKmu9QM4ZXepNXe49VvzVXWQReVdqHZVIoBirK2jziul', ...
            char(10), ...
            'Tk6/0puMuOE0eusFC5A32LN8f+HYVX4fpiKVeXYW0FLOQOf1eBF3EzOizyqiazEC', ...
            char(10), ...
            'ErUwlog0RBjNBmfohhrmy58T1qMsMd8HzA4BwVCVcndFPibFDm+8ckpG1vmNn0f0', ...
            char(10), ...
            'Kea7Nsb1wZZIvtKkUy1iwJwsYAtvdM7e+UC7c5DjJ5v/sxu+yOJosOg15QcKzvHA', ...
            char(10), ...
            'FmK4kxk4g7O4tdpi6M9j+ABbCdLsCA8gOhflj9+O5WSEsr8eKDbHRrQ6Bhr4uzIK', ...
            char(10), ...
            '8ZidpyWXFfMdAuLn13+MaI38K2adioccESgPwwIDAQABAoIBAE0WTSsl4yptPDDk', ...
            char(10), ...
            'kkjaA8Zx3JSxbFYDPyYLmRiSHqGrrFPOK+fHp58cZFmoBGybBPPjGx6Q0WmIftsM', ...
            char(10), ...
            'SMDMjxHIn/dtNwIKKWRYVjDXEh9pXPki9jNzMiuenH0exCPLw95x1XblgmmMjL9/', ...
            char(10), ...
            'KJZs8PCjAIckuA6KBECdGVsY5VekmIWaB/Gx4I3RZMZL1Z+3gpBhLS54rxxRrZ2z', ...
            char(10), ...
            'HudoIXsabRipZwK8nDLTi2wNfgrE4xNaw/dMH/DIranaz2NKC4U0ibcbVtjQ108p', ...
            char(10), ...
            'hx84bl5rnyreBPMUMEv+6Sa2FUA9USeljN2RuoK/gzJCxRhwhxknkS/kpKPy/AS4', ...
            char(10), ...
            'LaXorEECgYEAt//dSazCpJHzZWGNGnZWqjgcPyCL5c5fMD+Qs+dZehW+O1gRpy2s', ...
            char(10), ...
            '5cNvl6hIJ2okrN5Wcy6emfrI0MI8zKGldRzDSeI02lmI5M/0hk4S51C6JvsDfUHa', ...
            char(10), ...
            'jchx0e1ulz78O32vb9Cq5aBbV/5XKF8s6KIKRZKwc/2+UZCliHsMw2UCgYEAssNk', ...
            char(10), ...
            'HoLOcgDz8bmRGSpYcJnRjwcaPV6SZmFau7HdMnLxsnfWmdyMYxp+IWd3hTuvflXf', ...
            char(10), ...
            '9BYRyKySQFzVFafOvrd5H6/HWWOfFTrpPER2qMgrg//bRlpibrnHN3Xsiz8BCptg', ...
            char(10), ...
            'aJXenRG2/Pv3DqlMruHRS+QmoWJEIvydRu3UWAcCgYA3ayYgWZtqa9cuUtpn/PqP', ...
            char(10), ...
            'XEUNsmTQe37qDkssFGM7xS69uwHeI4Cu11VWDUZmMK8JLhJFsOXuJL21OruLOqiW', ...
            char(10), ...
            'BGrBZxNaLJtxpzzT8tH4v7TBptrfMCV+jL/TZbrobP0Vgf6EJApFDS5V63Ie48On', ...
            char(10), ...
            '8Z48ZDknRma7NGDXIZCvjQKBgFToKW20g4nymet+UES7sDYLWVWt8fCkMrUeGJJ9', ...
            char(10), ...
            '8Ko9nj8+XFfIQYXw12fWVRabOseu0iiFMv01umGHtk4K3lAHpSg/vVff0Xer+4v8', ...
            char(10), ...
            'mL+iE8kmhWftFkOxScY15Jxe2IfJNQl35byE5X1T0AzOrPWDnH2HaDHPEr3rbmh6', ...
            char(10), ...
            'HhmRAoGAbHB5CX6kLMJOO5tjzh6yhPys9pMDZPZy8LDIcxC5ySUSIJZFGnNBbg3m', ...
            char(10), ...
            'PSaHTD9KSnZGlm+UWMlB6Vvhv4HmMvJddrHDuGbBCa3OeP4ovx5+DY/db5USitHU', ...
            char(10), ...
            'NzSMYqo8czGX/KmwHYCBePw8ZF+xGBYI/XM3YXeD6GVle2a97ds=', ...
            char(10), ...
            '-----END RSA PRIVATE KEY-----'];
            
            % Write the certificate PEM to disk
            pemId = fopen(fullfile(tempdir, 'test-cert-session.pem'), 'w');
            fwrite(pemId, pem_text);
            fclose(pemId);
            
            set(config, 'authentication_token', '');
            set(config, 'certificate_path', fullfile(tempdir, 'test-cert-session.pem'));
            
            session = Session();
            
            known_subject = 'CN=Christopher Jones A2108,O=Google,C=US,DC=cilogon,DC=org';
            known_expire_datetime = ...
                datetime('Dec  5 12:32:07 2015 GMT', ...
                'TimeZone', 'UTC', ...
                'InputFormat', 'MMM  d HH:mm:ss yyyy z', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSSSSSZ');
            known_expire_datenum = datenum(known_expire_datetime);
            actual_expire_datetime = ...
                datetime(session.expiration_date, ...
                'ConvertFrom', 'datetime', ...
                'TimeZone', 'UTC', ...
                'InputFormat', 'dd-MMM-yyyy HH:mm:ss ZZZZ', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSSSSSZ');
            actual_expire_datenum = datenum(actual_expire_datetime);
            
            known_type = 'X509 certificate';
            known_status = 'expired';
            
            assertEqual(testCase, known_subject, session.account_subject);
            assertEqual(testCase, known_expire_datenum, actual_expire_datenum);
            assertEqual(testCase, known_type, session.type);
            assertEqual(testCase, known_status, session.status);
            
            % Clean up
            set(config, 'authentication_token', saved_authentication_token);
            set(config, 'certificate_path', saved_certificate_path);
            delete(fullfile(tempdir, 'test-cert-session.pem'));
            upath = userpath;
            userdir = upath(1:end - 1);
            delete(fullfile(userdir, '.d1-auth-token-notified.txt'));
            import org.dataone.client.auth.CertificateManager;
            certmgr = CertificateManager.getInstance();
            certmgr.setCertificateLocation('');
        end
    end
    
end