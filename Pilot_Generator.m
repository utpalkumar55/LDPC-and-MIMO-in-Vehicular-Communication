function pilot_symbols = Pilot_Generator(number_of_symbol_per_subcarrier,number_of_transmit_antenna)

    pnseq = comm.PNSequence('Polynomial',[1 0 0 0 1 0 0 1], 'SamplesPerFrame', number_of_symbol_per_subcarrier,...
                            'InitialConditions',[1 1 1 1 1 1 1]); %% Generating PN sequence
    pilot = pnseq(); %% Creating pilot symbols
    pilots = repmat(pilot, 1, 4 ); %% Expanding to all pilot tones
    pilots = 2*double(pilots.'<1)-1; %% Converting bipolar to unipolar
    pilots(4,:) = -1*pilots(4,:); %% Inverting last pilot symbol
    pilot_symbols = repmat(pilots,[1, 1, number_of_transmit_antenna]); %% Generating pilot symbols for multiple antennas

end