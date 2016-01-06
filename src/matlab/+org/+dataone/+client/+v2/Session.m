% SESSION A class that provides an authenticated session based on configuration settings
%   The Session class uses configuration settings to provide credentials
%   when making requests to Member Nodes and Coordinating Nodes.  It uses
%   the either the Configuration.authentication_token property or the
%   Configuration.certificate_path property to create a Session object.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2016 DataONE
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

classdef Session < hgsetget
    
    properties (Access = 'private')
        
        % The underlying Java Session
        j_session;

    end
    
    properties
        
        % The account subject string from the authentication token or certificate
        account_subject;
        
        % The expiration date and time of the authentication token or certificate
        expiration_date;
               
        % The type of session (authentication token or X509 certificate)
        type;
        
        % The status of the session, either 'valid' or 'expired'
        status;
        
    end

    methods
        
        function session = Session()
            % SESSION Constructs a Session object using Configuration settings
            
            import org.dataone.client.auth.CertificateManager;
            import java.security.cert.X509Certificate;
            import org.dataone.client.configure.Configuration;
            import com.nimbusds.jose.JWSObject;
            
            session.j_session = org.dataone.service.types.v1.Session(); 
            
            % Get an authentication token or X509 certificate
            config = Configuration.loadConfig('');
            auth_token = config.get('authentication_token');
            cert_path = config.get('certificate_path');
            
            % Use auth tokens preferentially
            if ( ~isempty(auth_token) )
                import org.dataone.client.auth.AuthTokenSession;
                
                % Parse the token to get critical properties
                try
                    jwt = JWSObject.parse(java.lang.String(auth_token));
                    token_properties = ...
                        loadjson(char(jwt.getPayload().toString()));
                    session.account_subject = token_properties.userId;
                    expires = ...
                        addtodate( ...
                            datenum( ...
                                datetime( ...
                                    token_properties.issuedAt, ...
                                    'TimeZone', 'UTC', ...
                                    'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSZ' ...
                                ) ...
                            ), token_properties.ttl, 'millisecond');
                        
                        session.expiration_date = ...
                            datetime(expires, ...
                            'ConvertFrom', 'datenum', ...
                            'TimeZone', 'UTC', ...
                            'Format', 'dd-MMM-yyyy HH:mm:ss ZZZZ');
                        
                        session.type = 'authentication token';
                        
                        if ( session.isValid() )
                            session.status = 'valid';
                            
                        else
                            session.status = 'expired';
                            
                        end
                        
                catch parseException
                    error([char(10) ...
                        'There was a problem parsing the authentication token: ' ...
                        char(10) ...
                        auth_token ...
                        char(10) ...
                        ' Please ensure your authentication token is correct.']);
                    
                    % rethrow(parseException);
                    
                end
                j_session = AuthTokenSession(auth_token);
                
            % Otherwise use the X509 certificate
            elseif ( ~ isempty(cert_path) )
                CertificateManager.getInstance().setCertificateLocation(cert_path);
                cert = CertificateManager.getInstance().loadCertificate();
                
                session.account_subject = [];
                session.expiration_date = [];
                session.type = 'X509 certificate';
                session.status = [];
                
                if ( ~ isempty(cert) )
                    
                    formatter = java.text.SimpleDateFormat('dd-MMM-yyyy HH:mm:ss ZZZZ');
                    session.expiration_date = char( ...
                        formatter.format(cert.getNotAfter()));
                                        
                    subjectDN = CertificateManager.getInstance().getSubjectDN(cert);
                    session.account_subject = char( ...
                        CertificateManager.getInstance().standardizeDN( ...
                        subjectDN));
                    
                    if ( session.isValid() )
                        session.status = 'valid';
                        
                    else
                        session.status = 'expired';
                        
                    end
                end
            else
                if ( config.debug )
                    disp(['Both the ''Configuration.authentication_token'' ' ...
                        'and the Configuration.certificate_path ' ...
                        char(10) ...
                        'properties are empty. Using an anonymous, ' ...
                        'unauthenticated session.']);
                    
                end
            end
        end
        
        function is_valid = isValid(self)
            % ISVALID returns true if the session has not expired
            
            is_valid = false;
            
            % Compare the current time with the expiration date
            current_datetime = datetime('now', 'TimeZone', 'UTC');
            expiration_datetime = datetime(self.expiration_date, ...
                'ConvertFrom', 'datetime', ...
                'TimeZone', 'local', ...
                'InputFormat', 'dd-MMM-yyyy HH:mm:ss ZZZZ');
            if ( current_datetime < expiration_datetime)
                is_valid = true;
                
            end
        end
        
        function j_session = getJavaSession(self)
            % GETJAVASESSION returns the underlying Java Session object
            
            j_session = self.j_session;
            
        end
    end
end
