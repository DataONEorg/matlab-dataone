clear all
ncols=480;
nrows=296;
nodatavalue = -999.0;

%% Load input: SYNMAP land cover classification map; also read coordinate variables to re-use them later
grass_type=[19,20,21,22,23,24,25,26,27,38,41,42,43];
sncid=netcdf.open('inputs/land_cover/SYNMAP_NA_QD.nc', 'NC_NOWRITE');
fvid=netcdf.inqVarID(sncid, 'biome_frac');
frac=netcdf.getVar(sncid,fvid);
tvid=netcdf.inqVarID(sncid, 'biome_type');
type=netcdf.getVar(sncid,tvid);

lon_vid=netcdf.inqVarID(sncid, 'lon');
lon=netcdf.getVar(sncid,lon_vid);
lat_vid=netcdf.inqVarID(sncid, 'lat');
lat=netcdf.getVar(sncid,lat_vid);
lon_bnds_vid=netcdf.inqVarID(sncid, 'lon_bnds');
lon_bnds=netcdf.getVar(sncid,lon_bnds_vid);
lat_bnds_vid=netcdf.inqVarID(sncid, 'lat_bnds');
lat_bnds=netcdf.getVar(sncid,lat_bnds_vid);

netcdf.close(sncid)

%% Load input: long-term monthly mean air temperature data
Tair=zeros(ncols,nrows,12);
for m=1:12
    tncid=netcdf.open(strcat('inputs/narr_air.2m_monthly/air.2m_monthly_2000_2010_mean.',num2str(m),'.nc'), 'NC_NOWRITE');
    tvid=netcdf.inqVarID(tncid, 'Tair_monthly_mean');
    Tair(:,:,m)=netcdf.getVar(tncid,tvid);
    netcdf.close(tncid)
end

%% Load input: long-term monthly mean precipitation data
Rain=zeros(ncols,nrows,12);
for m=1:12
    rncid=netcdf.open(strcat('inputs/narr_apcp_rescaled_monthly/apcp_monthly_2000_2010_mean.',num2str(m),'.nc'), 'NC_NOWRITE');
    rvid=netcdf.inqVarID(rncid, 'apcp_monthly_mean');
    Rain(:,:,m)=netcdf.getVar(rncid,rvid);
    netcdf.close(rncid)
end

%% Initialize Grass Matrix
Grass=zeros(ncols,nrows);
for i=1:ncols
    for j=1:nrows
            Grass(i,j)=sum(frac(i,j,20:28))*0.5+sum(frac(i,j,43:44))*0.5+frac(i,j,39)*0.5+frac(i,j,42);
    end
end
  
%% Algorithm 1: method used in MstMIP
% examine the type of each pixel to see if it includes grass
C3=ones(ncols, nrows)*(-999.0);
C4=ones(ncols, nrows)*(-999.0);
for i=1:ncols
    for j=1:nrows
        frac_c3=0.0;
        frac_c4=0.0;
        if (Grass(i,j)>0)
            ngrow=0;
            nmonth_c3=0;
            nmonth_c4=0;
            for m=1:12
                if (Tair(i,j,m)>278)
                    ngrow=ngrow+1;
                end
                if (Tair(i,j,m)<295)
                    nmonth_c3=nmonth_c3+1;
                elseif (Tair(i,j,m)>=295 & Rain(i,j,m)>=2.5)
                    nmonth_c4=nmonth_c4+1;
                elseif (Tair(i,j,m)>=295 & Rain(i,j,m)<=2.5)
                    nmonth_c3=nmonth_c3+1;
                end
            end
            if (nmonth_c3==12)
                frac_c3=1;
                frac_c4=0.0;
            elseif (nmonth_c4>=1)
                frac_c4=nmonth_c4/ngrow;
                frac_c3=1-frac_c4;
            end
        end
            C3(i,j)=frac_c3;
            C4(i,j)=frac_c4;
    end
end            

%% Algorithm 2: a more complicated method
% examine the type of each pixel to see if it includes grass
%{
C3=ones(ncols, nrows)*(-999.0);
C4=ones(ncols, nrows)*(-999.0);
for i=1:ncols
    for j=1:nrows
        frac_c3=0.0;
        frac_c4=0.0;
        m_c4=0;
        if (Grass(i,j)>0)
            nmonth_c3=0;
            nmonth_c4=0;
            for m=1:12
                if (Tair(i,j,m)<295)
                    nmonth_c3=nmonth_c3+1;
                elseif (Tair(i,j,m)>=295 & Rain(i,j,m)>=2.5)
                    nmonth_c4=nmonth_c4+1;
                    m_c4(nmonth_c4)=m;
                elseif (Tair(i,j,m)>=295 & Rain(i,j,m)<=2.5)
                    nmonth_c3=nmonth_c3+1;
                end
            end
            if (nmonth_c3==12)
                frac_c3=1.0;
                frac_c4=0.0;
            elseif (nmonth_c4>=6)
                frac_c3=0;
                frac_c4=1;
            else
                frac_c4=nmonth_c4/12;
                frac_c3=1-frac_c4;
            end
        end
            C3(i,j)=frac_c3;
            C4(i,j)=frac_c4;
    end
end
%}

%% Output the netcdf file for C3 fraction
% reuse longitude, latitude, and boundary variables from land cover input file

moncid=netcdf.create('outputs/SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc', 'NC_CLOBBER');% create netCDF dataset (filename,mode)

mdid_lon = netcdf.defDim(moncid, 'lon', ncols);
mdid_lat = netcdf.defDim(moncid, 'lat', nrows);
mdid_nv = netcdf.defDim(moncid, 'nv', 2);

mvid_crs = netcdf.defVar(moncid, 'crs', 'char', []);
netcdf.putAtt(moncid, mvid_crs, 'grid_mapping_name', 'latitude_longitude');
netcdf.putAtt(moncid, mvid_crs, 'semi_major_axis', 6370997.0);
netcdf.putAtt(moncid, mvid_crs, 'inverse_flattening', 0.0);

mvid_lon = netcdf.defVar(moncid, 'lon', 'double', mdid_lon);
netcdf.putAtt(moncid, mvid_lon, 'standard_name', 'longitude');
netcdf.putAtt(moncid, mvid_lon, 'long_name', 'longitude coordinate');
netcdf.putAtt(moncid, mvid_lon, 'units', 'degrees_east');
netcdf.putAtt(moncid, mvid_lon, 'bounds', 'lon_bnds');

mvid_lat = netcdf.defVar(moncid, 'lat', 'double', mdid_lat);
netcdf.putAtt(moncid, mvid_lat, 'standard_name', 'latitude');
netcdf.putAtt(moncid, mvid_lat, 'long_name', 'latitude coordinate');
netcdf.putAtt(moncid, mvid_lat, 'units', 'degrees_north');
netcdf.putAtt(moncid, mvid_lat, 'bounds', 'lat_bnds');

mvid_lon_bnds = netcdf.defVar(moncid, 'lon_bnds', 'double', [mdid_nv, mdid_lon]);
mvid_lat_bnds = netcdf.defVar(moncid, 'lat_bnds', 'double', [mdid_nv, mdid_lat]);

mvid_data = netcdf.defVar(moncid, 'C3_frac', 'double', [mdid_lon, mdid_lat]);
netcdf.putAtt(moncid, mvid_data, 'long_name', 'relative fraction of C3 grass based on potential SYNMAP');
%netcdf.putAtt(moncid, mvid_data, 'units', ovunits);
%netcdf.putAtt(moncid, mvid_data, 'cell_methods', ocell_methods);
%netcdf.putAtt(moncid, mvid_data, '_FillValue', nodatavalue);
netcdf.putAtt(moncid, mvid_data, 'missing_value', nodatavalue);
netcdf.putAtt(moncid, mvid_data, 'grid_mapping', 'crs');

% put global attributes
netcdf.putAtt(moncid, netcdf.getConstant('GLOBAL'), 'Conventions', 'CF-1.4');
netcdf.putAtt(moncid, netcdf.getConstant('GLOBAL'), 'version', '2.0');

% Enter into data mode to write data
netcdf.endDef(moncid);

% Put aux data in long term mean data
netcdf.putVar(moncid, mvid_lon, lon);
netcdf.putVar(moncid, mvid_lat, lat);
netcdf.putVar(moncid, mvid_lon_bnds, lon_bnds);
netcdf.putVar(moncid, mvid_lat_bnds, lat_bnds);
netcdf.putVar(moncid, mvid_data, C3);

netcdf.close(moncid)

%% Output the netcdf file for C4 fraction
% reuse longitude, latitude, and boundary variables from land cover input file
moncid=netcdf.create('outputs/SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc', 'NC_CLOBBER');% create netCDF dataset (filename,mode)

mdid_lon = netcdf.defDim(moncid, 'lon', ncols);
mdid_lat = netcdf.defDim(moncid, 'lat', nrows);
mdid_nv = netcdf.defDim(moncid, 'nv', 2);

mvid_crs = netcdf.defVar(moncid, 'crs', 'char', []);
netcdf.putAtt(moncid, mvid_crs, 'grid_mapping_name', 'latitude_longitude');
netcdf.putAtt(moncid, mvid_crs, 'semi_major_axis', 6370997.0);
netcdf.putAtt(moncid, mvid_crs, 'inverse_flattening', 0.0);

mvid_lon = netcdf.defVar(moncid, 'lon', 'double', mdid_lon);
netcdf.putAtt(moncid, mvid_lon, 'standard_name', 'longitude');
netcdf.putAtt(moncid, mvid_lon, 'long_name', 'longitude coordinate');
netcdf.putAtt(moncid, mvid_lon, 'units', 'degrees_east');
netcdf.putAtt(moncid, mvid_lon, 'bounds', 'lon_bnds');

mvid_lat = netcdf.defVar(moncid, 'lat', 'double', mdid_lat);
netcdf.putAtt(moncid, mvid_lat, 'standard_name', 'latitude');
netcdf.putAtt(moncid, mvid_lat, 'long_name', 'latitude coordinate');
netcdf.putAtt(moncid, mvid_lat, 'units', 'degrees_north');
netcdf.putAtt(moncid, mvid_lat, 'bounds', 'lat_bnds');

mvid_lon_bnds = netcdf.defVar(moncid, 'lon_bnds', 'double', [mdid_nv, mdid_lon]);
mvid_lat_bnds = netcdf.defVar(moncid, 'lat_bnds', 'double', [mdid_nv, mdid_lat]);

mvid_data = netcdf.defVar(moncid, 'C4_frac', 'double', [mdid_lon, mdid_lat]);
netcdf.putAtt(moncid, mvid_data, 'long_name', 'relative fraction of C4 grass based on potential SYNMAP');
%netcdf.putAtt(moncid, mvid_data, 'units', ovunits);
%netcdf.putAtt(moncid, mvid_data, 'cell_methods', ocell_methods);
%netcdf.putAtt(moncid, mvid_data, '_FillValue', nodatavalue);
netcdf.putAtt(moncid, mvid_data, 'missing_value', nodatavalue);
netcdf.putAtt(moncid, mvid_data, 'grid_mapping', 'crs');

% put global attributes
netcdf.putAtt(moncid, netcdf.getConstant('GLOBAL'), 'Conventions', 'CF-1.4');
netcdf.putAtt(moncid, netcdf.getConstant('GLOBAL'), 'version', '2.0');

% Enter into data mode to write data
netcdf.endDef(moncid);

% Put aux data in long term mean data
netcdf.putVar(moncid, mvid_lon, lon);
netcdf.putVar(moncid, mvid_lat, lat);
netcdf.putVar(moncid, mvid_lon_bnds, lon_bnds);
netcdf.putVar(moncid, mvid_lat_bnds, lat_bnds);
netcdf.putVar(moncid, mvid_data, C4);

netcdf.close(moncid)

%% Output the netcdf file for Grass fraction
% reuse longitude, latitude, and boundary variables from land cover input file
moncid=netcdf.create('outputs/SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc', 'NC_CLOBBER');% create netCDF dataset (filename,mode)

mdid_lon = netcdf.defDim(moncid, 'lon', ncols);
mdid_lat = netcdf.defDim(moncid, 'lat', nrows);
mdid_nv = netcdf.defDim(moncid, 'nv', 2);

mvid_crs = netcdf.defVar(moncid, 'crs', 'char', []);%variable name is 'crs'? type 'char'
netcdf.putAtt(moncid, mvid_crs, 'grid_mapping_name', 'latitude_longitude');
netcdf.putAtt(moncid, mvid_crs, 'semi_major_axis', 6370997.0);
netcdf.putAtt(moncid, mvid_crs, 'inverse_flattening', 0.0);

mvid_lon = netcdf.defVar(moncid, 'lon', 'double', mdid_lon);
netcdf.putAtt(moncid, mvid_lon, 'standard_name', 'longitude');
netcdf.putAtt(moncid, mvid_lon, 'long_name', 'longitude coordinate');
netcdf.putAtt(moncid, mvid_lon, 'units', 'degrees_east');
netcdf.putAtt(moncid, mvid_lon, 'bounds', 'lon_bnds');

mvid_lat = netcdf.defVar(moncid, 'lat', 'double', mdid_lat);
netcdf.putAtt(moncid, mvid_lat, 'standard_name', 'latitude');
netcdf.putAtt(moncid, mvid_lat, 'long_name', 'latitude coordinate');
netcdf.putAtt(moncid, mvid_lat, 'units', 'degrees_north');
netcdf.putAtt(moncid, mvid_lat, 'bounds', 'lat_bnds');

mvid_lon_bnds = netcdf.defVar(moncid, 'lon_bnds', 'double', [mdid_nv, mdid_lon]);
mvid_lat_bnds = netcdf.defVar(moncid, 'lat_bnds', 'double', [mdid_nv, mdid_lat]);

mvid_data = netcdf.defVar(moncid, 'grass', 'double', [mdid_lon, mdid_lat]);
netcdf.putAtt(moncid, mvid_data, 'long_name', 'grass fraction based on potential SYNMAP');
%netcdf.putAtt(moncid, mvid_data, 'units', ovunits);
%netcdf.putAtt(moncid, mvid_data, 'cell_methods', ocell_methods);
%netcdf.putAtt(moncid, mvid_data, '_FillValue', nodatavalue);
netcdf.putAtt(moncid, mvid_data, 'missing_value', nodatavalue);
netcdf.putAtt(moncid, mvid_data, 'grid_mapping', 'crs');

% put global attributes
netcdf.putAtt(moncid, netcdf.getConstant('GLOBAL'), 'Conventions', 'CF-1.4');
netcdf.putAtt(moncid, netcdf.getConstant('GLOBAL'), 'version', '1.0');

% Enter into data mode to write data
netcdf.endDef(moncid);

% Put aux data in long term mean data
netcdf.putVar(moncid, mvid_lon, lon);
netcdf.putVar(moncid, mvid_lat, lat);
netcdf.putVar(moncid, mvid_lon_bnds, lon_bnds);
netcdf.putVar(moncid, mvid_lat_bnds, lat_bnds);
netcdf.putVar(moncid, mvid_data, Grass);

netcdf.close(moncid)
