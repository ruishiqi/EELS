function [dm3struct] = DM3Import0( dm3filename )
    global dm3file;
    global endianstyle;

    % Search for .dm3 file extension.  If not present, append it.
    location = regexp( dm3filename, '\.dm3', 'ONCE' );
    if( isempty(location) )
        dm3filename = [dm3filename, '.dm3' ];
    end
    [dm3file, message] = fopen( dm3filename, 'r', 'b' );
    if dm3file == -1
        % Error on file open
        dm3struct = [];
        warning( message );
        return
    end
    dm3fileinfo = fread( dm3file, 3, 'uint32');
    if dm3fileinfo(1) ~= 3
        error( 'File not in .DM3 format' )
    end
    if dm3fileinfo(3) == 0
        endianstyle = 'b'; % Data in big-endian format
    elseif dm3fileinfo(3) == 1
        endianstyle = 'l'; % Data in little-endian format
    end
    dm3struct = struct();
    
    frewind(dm3file);
    metadm3file = fread(dm3file, 'uchar=>char' )';
    N = numel(metadm3file);
    
    datatypeloc = regexp( metadm3file, 'DataType%%%%' );
    datatype = zeros( size( datatypeloc) );
    % Count the number of spectra and images
    for index = 1:numel(datatypeloc)
        datatype(index) = uint8(metadm3file(datatypeloc(index)+20));
    end

    spectracount = sum( datatype == 2 );

    dataloc = regexp( metadm3file, 'Data%%%%' ); % Search whole file for Data%%%% tags
    
    spectraindex = 0;
    for index = 1:numel(datatypeloc)
        % Initialize dimensions
        ydim = 1; % may be overwritten, if greater than one
        zdim = 1; % may be overwritten, if great than one
         
        if( datatype(index) == 23 ) 
        elseif( datatype(index) == 2 ) % Spectra (maybe, DM3 is very inconsistent)
            spectraindex = spectraindex + 1;

            dimensionloc = regexp( metadm3file(datatypeloc(index):N), 'Dimensions' );
            dimensionloc = dimensionloc(1) + datatypeloc(index) -1;
            
            pixeldepthloc = regexp( metadm3file(datatypeloc(index):N), 'PixelDepth' );
            pixeldepthloc = pixeldepthloc(1) + datatypeloc(index) -1;
            
            if( isempty( pixeldepthloc ) )
                warning( 'PixelDepth location not found, script may crash' )
            end

            xdimloc = regexp( metadm3file(dimensionloc:pixeldepthloc), '%%%%' );
            xdimloc = xdimloc(1) + dimensionloc - 1;
            xdim = readTagData( xdimloc );
            ydimloc = regexp( metadm3file(xdimloc+4:pixeldepthloc), '%%%%' );
            % disp( 'FIXME: trying to understand parsing' );
            ydimloc = ydimloc(1) + (xdimloc+4) - 1;
            % Check for spectral image third %%%%
            zdimloc = regexp( metadm3file(ydimloc+4:pixeldepthloc), '%%%%' );
            zdimloc = zdimloc(1) + (ydimloc+4) - 1;
            %disp( 'Parsing Spectral Image' );
            ydim = readTagData( ydimloc );
            zdim = readTagData( zdimloc );
            ddd= reshape( readTagData( dataloc(index) ), xdim, ydim, zdim );
            for iii=1:ydim
                for jjj=1:xdim
                    dm3struct.data(iii,jjj,:)=ddd(jjj,iii,:);
                end
            end
            clear iii
            clear jjj
            clear ddd
        end
        
    end

    
    calibrateloc = regexp( metadm3file, 'Calibrations' );
    for spectraindex = 1:spectracount
        calibrateloc_curr = calibrateloc(spectraindex+1);
        % This can probably be done vector wise with the ? operator.
        temploc = regexp( metadm3file, 'Scale%%%%' );
        scaleloc = [];
        for index = 1:numel(temploc)
            if temploc(index) > calibrateloc_curr
                scaleloc = [scaleloc, temploc(index)];
            end
        end
        temploc = regexp( metadm3file, 'Origin%%%%' );
        originloc = [];
        for index = 1:numel(temploc)
            if temploc(index) > calibrateloc_curr
                originloc = [originloc, temploc(index)];
            end
        end
        temploc = regexp( metadm3file, 'Units%%%%' );
        unitloc = [];
        for index = 1:numel(temploc)
            if temploc(index) > calibrateloc_curr
                unitloc = [unitloc, temploc(index)];
            end
        end
        
        xaxis = struct( 'scale', readTagData( scaleloc(2) ), ...
            'origin', readTagData( originloc(2) ), ...
            'units', char( readTagData( unitloc(2) ).' ) );
        dm3struct.yscale=xaxis.scale;
        
        % There may not be a y-axis for spectra
        if( ydim ~= 1 )
            yaxis = struct( 'scale', readTagData( scaleloc(3) ), ...
                'origin', readTagData( originloc(3) ), ...
                'units', char( readTagData( unitloc(3) ).' ) );
            dm3struct.xscale=yaxis.scale;
        end
        % There is typically only a z-axis for spectral images
        if( zdim ~= 1 )
            zaxis = struct( 'scale', readTagData( scaleloc(4) ), ...
                'origin', readTagData( originloc(4) ), ...
                'units', char( readTagData( unitloc(4) ).' ) );
            dm3struct.escale=zaxis.scale*1000;
        end
        dm3struct.edim=length(dm3struct.data(1,1,:));
        dm3struct.ene=((1:dm3struct.edim)-zaxis.origin)*dm3struct.escale;
    end
    

% scale6 is the intensity scale, scale7/8 are the x-y dimension
% scales.
    
    % Many of these microscope data tags may not exist, hence the need for isempty checks  
    magloc = regexp( metadm3file, 'Indicated Magnification%%%%' );
    if( ~ isempty( magloc ) )
        dm3struct.mag = readTagData( magloc(1) );
    end
    voltloc = regexp( metadm3file, 'Voltage%%%%' );
    if( ~ isempty( voltloc ) )
        dm3struct.voltage_kV = readTagData( voltloc(1) );
    end
    opmodeloc = regexp( metadm3file, 'Operation Mode%%%%' );
    if( ~ isempty( opmodeloc ) )
        % For whatever reason this is stored as an array and not a string.
        dm3struct.operation_mode = char( readTagData( opmodeloc(1) ).' );
    end 
    ecurrentloc = regexp( metadm3file, 'Emission Current \(µA\)%%%%');
    if( ~ isempty( ecurrentloc ) )
        dm3struct.emission_current_uA = readTagData( ecurrentloc(1) );
    end
    csloc = regexp( metadm3file, 'Cs\(mm\)%%%%' );
    if( ~ isempty( csloc ) )
        dm3struct.Cs_mm = readTagData( csloc(1) );
    end
    pcurrentloc = regexp( metadm3file, 'Probe Current \(nA\)%%%%' );
    if( ~ isempty( pcurrentloc ) )
        dm3struct.probe_current_nA = readTagData( pcurrentloc(1) );
    end
    psizeloc = regexp( metadm3file, 'Probe Size \(nm\)%%%%' );
    if( ~ isempty( psizeloc ) )
        dm3struct.probe_size_nm = readTagData( psizeloc(1) );
    end
    



    specimenloc = regexp( metadm3file, 'Specimen%%%%' );
    if( ~ isempty( specimenloc ) )
        % For whatever reason this is stored as an array and not a string.
        dm3struct.specimen_info = char( readTagData( specimenloc(1) ).' );
    end
    opnameloc = regexp( metadm3file, 'Operator%%%%' );
    if( ~ isempty( opnameloc ) )
        % For whatever reason this is stored as an array and not a string.
        dm3struct.operator_name = char( readTagData( opnameloc(1) ).' );
    end
    micronameloc = regexp( metadm3file, 'Microscope%%%%' );
    if( ~ isempty( micronameloc ) )
        % For whatever reason this is stored as an array and not a string.
        dm3struct.microscope_name = char( readTagData( micronameloc(1) ).' );
    end
    
    TGHitachiloc = regexp( metadm3file, 'Hitachi' );
    if( ~ isempty( TGHitachiloc ) )
        % For whatever reason this is stored as an array and not a string.
        dm3struct.Hitachi = readTagGroupData( TGHitachiloc(1) );
    end
    
    imagetextlocs = regexp(metadm3file, 'Text%%%%'); %find all image_text instances
    if( ~ isempty( imagetextlocs ) )
        for k=1:length(imagetextlocs)
            image_text = char( readTagData( imagetextlocs(k) ).' ); 
            image_text = regexprep(image_text,char(8232),char(10)); %change dm3 newline to matlab newline
            dm3struct.image_text{k} = image_text;
        end
    end
    
    fclose(dm3file);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tgd] = readTagGroupData( fileloc )
    % Read in a TagGroup and assign structure fieldnames using tag labels
    % This function was written by Michael Bergen

    global dm3file;
    
    fseek( dm3file, fileloc-3 , 'bof' );
    labelsize = fread( dm3file, 1, 'short' );

    %this label is not used
    if( labelsize ~= 0 )
        label = fread( dm3file, labelsize, 'uchar=>char')';
    end
    % Read in the 1000 crap and throw it away
    fread( dm3file, 5, 'uchar' );
    numSubTags = fread(dm3file, 1, 'uchar' );
    for k=1:numSubTags
        tagType = fread(dm3file, 1, 'uchar' );
        labelsize = fread( dm3file, 1, 'short' );

        %location to pass to readTagData or readTagGroupData
        currfileloc = ftell(dm3file); 

        % label is used to define structure fieldnames
        if( labelsize ~= 0 )
            label = fread( dm3file, labelsize, 'uchar=>char')';
        end
        
        if(tagType == 20) %a sub tag group
            
            tgd.(label) = readTagGroupData(currfileloc+1); %recursive
        elseif(tagType == 21) %just a tag
            
            tgd.(label) = char( readTagData( currfileloc+1 ).' );
        end
    end
       
    
end

function [td] = readTagData( fileloc )
    global dm3file;
    global endianstyle;

    % Set the file positon to the beginning of the matched regular
    % expression
    % File_location - 1 is the actual location of the start of the label
    % (since MATLAB arrays start counting at 1).
    % File_location - 3 is number of characters (bytes) in the label, so
    % we can read in and discard that information.
    fseek( dm3file, fileloc-3 , 'bof' );
    labelsize = fread( dm3file, 1, 'short' );
    % CURRENTLY NOT USING THE LABEL
    if( labelsize ~= 0 )
        label = fread( dm3file, labelsize, 'uchar=>char')';
    end
    % Read in the %%%% crap and throw it away
    fread( dm3file, 4, 'uchar' );
    
    % Ndef is number of data definitions, 
    %     for a simple type this will = 1,
    %     for a string this will = 2,
    %     an array of a simple type will = 3,
    %     structs have 1+2*f where f=number of fields in struct
    % I don't actuall seem to use Ndef...
    Ndef = fread(dm3file, 1, 'uint32' );
    tagdatatype = parseDataType();

    switch tagdatatype
    case 'DM3array'
        td = readDM3Array();
    case 'DM3string'
        % Strings are in _unicode_ (2 byte/char) format
        td = readDM3String();
    case 'DM3struct'
        % A 'simple' structure.
        td = readDM3Struct();
    case 'empty'
            % Do nothing;
        td = [];
    otherwise % simple type
        td = fread(dm3file, 1, tagdatatype, 0, endianstyle );
    end % case


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [typestring] = parseDataType()
    global dm3file;
    % Function parses the next 4 bytes and returns a string that represents the
    % associated data type.

    tagdatatype = fread(dm3file, 1, 'uint32' );

    % Parse tagdatatypes into MATLAB types
    % SHORT   = 2,
    % LONG    = 3,
    % USHORT  = 4,
    % ULONG   = 5,
    % FLOAT   = 6,
    % DOUBLE  = 7,
    % BOOLEAN = 8,
    % CHAR    = 9,
    % OCTET   = 10, i.e. a byte
    % STRUCT  = 15,
    % STRING  = 18,
    % ARRAY   = 20
    if( isempty( tagdatatype ) )
        disp( 'Warning, parseDataType: ignoring empty Tag' );
        typestring = 'empty';
    else
        switch tagdatatype
        case 2
            typestring = 'short';
        case 3
            typestring = 'long';
        case 4
            typestring = 'uint16';
        case 5
            typestring = 'uint32';
        case 6
            typestring = 'float32';
        case 7
            typestring = 'double';
        case 8
            typestring = 'ubit8';
        case 9
            typestring = 'uchar';
        case 10
            typestring = 'uint8';
        case 15
            typestring = 'DM3struct';
        case 18
            typestring = 'DM3string';
        case 20
            typestring = 'DM3array';
        otherwise
            error( strcat('Parse Error, unknown data TagType found: ', int2str(tagdatatype) ) );
        end % case
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [td] = readDM3Array()
    global dm3file;
    global endianstyle;
    
        %Hopefully the program doesn't do arrays of arrays or strings or 
    %there will be a bug to deal with.
    tagdatatype = parseDataType();
    arraylength = fread(dm3file, 1, 'uint32' );
    td = zeros( arraylength, 1 );
    
    if strcmp( tagdatatype, 'DM3struct' )
        % Ugh, the ever fun array of structs
        disp( 'I assume any array of struct is a complex image' )
        for index = 1:arraylength
            td(index) = readDM3Struct();
        end
    elseif strcmp( tagdatatype, 'DM3array' )
        %The slightly less enjoyable array or arrays
        disp( 'I do not read arrays of arrays' );
%         for index = 1:arraylength
%             td(index) = readDM3Array();
%         end
    elseif strcmp( tagdatatype, 'DM3string' )
        % And last the array of strings..
        disp('I do not read arrays of strings' );
%         for index = 1:arraylength
%             td(index) = readDM3String();
%         end
    elseif strcmp( tagdatatype, 'empty' )
        % Do nothing.
    else % a simple array
        td = fread(dm3file, arraylength, tagdatatype, 0, endianstyle);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [s] = readDM3Struct()
    global dm3file;
    global endianstyle;
    % This function only reads simple structs.  If the DM3 files contains
    % other structs, strings, or arrays inside the struct this function
    % will force an error.
    
    % Struct name length is usually == 0
    structnamelength = fread(dm3file, 1, 'uint32' );
    Nfields = fread(dm3file, 1, 'uint32' );
    
        % Note that 'fieldsnamelength' is often zero, hopefully fread handles
    % this gracefully or debugging may be necessary.
    fieldsnamelength = zeros( Nfields, 1 );
    fieldsdatatype = cell( Nfields, 1 );
    for index = 1:Nfields
        % Note that fieldsnamelength(i) is often zero, and when this is the
        % case it doesn't appear to exist at all...
        fieldsnamelength(index) = fread(dm3file, 1, 'uint32' );
        fieldsdatatype(index) = {parseDataType()};
    end
    
    % Now read in the struct data.  Can structs contain arrays, other
    % structs, or strings?  Most likely...
    if( structnamelength ~= 0 )
        s.name =  fread(dm3file,structnamelength,'uchar');
    else
        %s.name = '';
    end
    
    % Pre-allocation
    s.names = zeros( Nfields, 1 );
    s.data = zeros( Nfields, 1 );
    % Read in field names and field data
    for index = 1:Nfields
        if fieldsnamelength(index) ~= 0
            s.names(index) = fread(dm3file,fieldsnamelength,'uchar');
        else
            %s.fieldnames(index) = [];
        end
        
        if strcmp( fieldsdatatype(index), 'DM3struct' )
            % Ugh, the ever fun struct of structs
            error( 'I do not parse structs in a struct' );
        elseif strcmp( fieldsdatatype(index), 'DM3array' )
            %The slightly less enjoyable array in a struct
            error( 'I do not parse arrays in a struct' );
        elseif strcmp( fieldsdatatype(index), 'DM3string' )
            % And last the string in a struct
            error( 'I do not parse strings in a struct' );
        else % a simple struct field element
            s.data(index) = fread(dm3file,1,char(fieldsdatatype(index)),0,endianstyle);
        end
        
    end
    
end

function [s] = readDM3String( )
    global dm3file;
    % Strings are in _unicode_ (2 byte/char) format
    arraylength = fread(dm3file, 1, 'uint32' );
    rawstring = fread(dm3file, arraylength, '*char' )';
    s = char( rawstring.' );
    % If this doesn't work use the skip functionality of fread
end
