% Returns the human-readable name of a row, col field of a MET5 reticle
% @param {uint8 1x1} [row = 1] - row of the reticle
% @param {uint8 1x1} [col = 1] - column of the reticle
% @param {char 1xm} [reticle = 'IMO261711'] - name of the reticle

function  c  = getNameOfReticleField(varargin)

    p = inputParser;
    
    % is scalar returns true if size = [1 1]

    addParameter(p, 'row', 1, @(x) isscalar(x) && isnumeric(x) && (x > 0) && (x <= 19))
    addParameter(p, 'col', 1, @(x) isscalar(x) && isnumeric(x) && (x > 0) && (x <= 19))
    addParameter(p, 'reticle', 'IMO261711', @(x) ischar(x) && (x > 0) && (x <= 19))


    parse(p, varargin{:});

    row = p.Results.row;
    col = p.Results.col;
    reticle = p.Results.reticle; % unused for now
    
    
    % For now ignore cReticle
    
    c = 'Not Specified';

    switch row
        case 1
            switch col
                case num2cell(1:10)
                    c = 'Pupil Fill Monitor';
                case num2cell(11 : 19)
                    c = 'Clear';
            end
        case 2
            switch col
                case num2cell(1 : 5)
                    c = 'Illumination Monitor';
                case num2cell(6 : 10)
                    c = 'Illumination Monitor on Grating';
                case num2cell(11 : 15) 
                    c = 'SE Line Space Bias BF';
                case num2cell(16 : 19)
                    c = 'SE Line Space Bias DF';
            end
        case 3
            switch col
                case num2cell(1 : 5)
                    c = 'SE Line Space Cleave BF';
                case num2cell(6 : 10)
                    c = 'Se Line Space Cleave DF';
                case num2cell(11 : 15) 
                    c = 'SE Line End And Distortion BF';
                case num2cell(16 : 19)
                    c = 'SE Line End And Distortion DF';
            end
        case 4
            switch col
                case num2cell(1 : 5)
                    c = 'SE Contact Bias Split BF';
                case num2cell(6 : 10)
                    c = 'Se Contact Bias Split DF';
                case num2cell(11 : 15) 
                    c = 'Contact Bias BF';
                case num2cell(16 : 19)
                    c = 'Contact Bias DF';
            end
        case 5
            switch col
                case num2cell(1:10)
                    c = 'SE Contact Cleave 1:6 BF';
                case num2cell(11 : 19)
                    c = 'SE Contact Cleave 1:6 DF';
            end
        case 6
            switch col
                case num2cell(1 : 6)
                    c = 'F2X';
                case num2cell(7 : 12)
                    c = 'F2X Cleave';
                case num2cell(13 : 19)
                    c = 'F2X Contact';
            end
        case 7
            switch col
                case num2cell(1 : 4)
                    c = 'Aberration Monitor BF';
                case num2cell(5 : 8)
                    c = 'Aberration Minitor DF';
                case num2cell(9 : 12)
                    c = 'Aberration Monitor LBF';
                case num2cell1(3 : 16) 
                    c = 'F2X Aberration Monitor';
                case num2cell1(7 : 19)
                    c = 'Zoneplate DF';
            end
        case 8 
            switch col
                case num2cell(1:10)
                    c = 'SE Contact Cleave 1:1 BF';
                case num2cell(11 : 19)
                    c = 'SE Contact Cleave 1:1 DF';
            end
    end
    

end

