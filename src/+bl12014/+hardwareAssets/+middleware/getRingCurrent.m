function beamCurrent = getRingCurrent()
    % Get the ring current from the middleware
    % 
    % :return: The ring current in mA
    % :rtype: float
    % 
    % .. seealso:: :func:`getRingVoltage`
    %


    url = 'https://controls.als.lbl.gov/als-beamstatus/curvals?v=1.27';

    % Fetch the raw data from the API (as a character array)
    rawData = webread(url);

    % Decode the JSON data into a MATLAB structure
    data = jsondecode(rawData);

    % Find the beam current in the returned JSON structure
    beamCurrent = [];

    for i = 1:length(data)
        if strcmp(data(i).label, 'Beam Current')
            beamCurrent = data(i).val;
            break;
        end
    end

end
