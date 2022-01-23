%%% Initializing the resource block parameters based on channel bandwidth
if channel_bandwidth == 10e6
    subcarrier_spacing = 156.25e3; %% Initializing the subcarrier spacing in Hz
    symbol_duration = 1/subcarrier_spacing; %% Initializing symbol duration
    cyclic_prefix_duration = symbol_duration * 0.0703125; %% Initializing cyclic prefix duration
    number_of_symbol_per_subcarrier = floor((1 * 1000e-6) / (symbol_duration + cyclic_prefix_duration)); %% Initializing the number of symbols per subcarrier
    guard_bandwidth = 2.500e6; %% Initializing the guard bandwidth [20% of channel bandwidth]
    guard_interval = 1/guard_bandwidth; %% Initializing guard interval
    number_of_resource_block = (channel_bandwidth - guard_bandwidth) / (number_of_data_subcarrier * subcarrier_spacing); %% Initializing the number of resource block 
    sampling_frequency = subcarrier_spacing * number_of_total_subcarrier * number_of_resource_block; %% Initializing sampling frequency
    fft_length = 64; %% Initializing FFT length
    cyclic_prefix_length = ceil(fft_length * 0.0703125); %% Initializing cyclic prefix length [7.03125% of fft length]
    guard_band = [floor(fft_length * 0.10); floor(fft_length * 0.10)]; %% Initializing guard band
end
%%% Initializing the resource block parameters based on channel bandwidth

%%% Preparing data subcarrier indices and pilot subcarrier indices for multiple resource blocks in a frame
margin = (fft_length - sum(guard_band) - (number_of_resource_block * number_of_total_subcarrier)) / 2;
index = guard_band(1) + margin;
for resource_block = 1:number_of_resource_block
    if resource_block == 1
        data_subcarrier_indices = data_subcarrier_indices_per_symbol + index;
        pilot_subcarrier_indices = pilot_subcarrier_indices_per_symbol + index;
    else
        data_subcarrier_indices = [data_subcarrier_indices, data_subcarrier_indices_per_symbol + index];
        pilot_subcarrier_indices = [pilot_subcarrier_indices; pilot_subcarrier_indices_per_symbol + index];
    end
    index = data_subcarrier_indices(end);
end
%%% Preparing data subcarrier indices and pilot subcarrier indices for multiple resource blocks in a frame

%%% Initializing OFDM Modulator and Demodulator
ofdm_mod = comm.OFDMModulator('FFTLength' , fft_length, 'NumGuardBandCarriers', guard_band, ...
                                'PilotInputPort', true, 'PilotCarrierIndices', pilot_subcarrier_indices, ...
                                'CyclicPrefixLength', cyclic_prefix_length, 'NumSymbols', number_of_symbol_per_subcarrier,...
                                'NumTransmitAntennas',  number_of_transmit_antenna);

ofdm_demod = comm.OFDMDemodulator('FFTLength' , fft_length, 'NumGuardBandCarriers', guard_band, ...
                                    'PilotOutputPort', true, 'PilotCarrierIndices', pilot_subcarrier_indices, ...
                                    'CyclicPrefixLength', cyclic_prefix_length, 'NumSymbols', number_of_symbol_per_subcarrier, ...
                                    'NumReceiveAntennas', number_of_receive_antenna);
%%% Initializing OFDM Modulator and Demodulator
                                
%%% Initializing modulation parameters
if modulation_type == 1 %% Initializing modulation parameters for QPSK modulation
    number_of_bits_per_symbol = 2;
    modulator = comm.PSKModulator('ModulationOrder', 4, 'BitInput', true,...
        'PhaseOffset', pi/4, 'SymbolMapping', 'Custom', 'CustomSymbolMapping', [0 2 3 1]);
    demodulator_hard = comm.PSKDemodulator('ModulationOrder', 4, 'BitOutput',true, ...
        'PhaseOffset', pi/4, 'SymbolMapping', 'Custom', 'CustomSymbolMapping', [0 2 3 1], ...
        'DecisionMethod','Hard decision');
    demodulator_soft = comm.PSKDemodulator('ModulationOrder', 4, 'BitOutput',true, ...
        'PhaseOffset', pi/4, 'SymbolMapping', 'Custom', 'CustomSymbolMapping', [0 2 3 1], ...
        'DecisionMethod','Log-likelihood ratio');
end
%%% Initializing modulation parameters

%%% Initializing Channel Models
delay_spread = cyclic_prefix_length - 1; %% Initializing delay spread in the channel
number_of_paths= 5; %% Initializing number of paths for fading 
path_delay = floor(linspace(0, delay_spread, number_of_paths))*(1/sampling_frequency); %% Initializing path delay for each path
path_gain  = zeros(size(path_delay));
for i=2:number_of_paths
    path_gain(i) = path_gain(i - 1) - abs(randn); %% Initializing path gain for each path
end

mimo_fading_channel = comm.MIMOChannel('SampleRate', sampling_frequency, 'MaximumDopplerShift', doppler_effect, ...
                                    'PathDelays', path_delay, 'AveragePathGains', path_gain,...
                                    'TransmitCorrelationMatrix', eye(number_of_transmit_antenna),...
                                    'ReceiveCorrelationMatrix', eye(number_of_receive_antenna),...
                                    'PathGainsOutputPort', true, 'NormalizePathGains', true, 'NormalizeChannelOutputs', true);

awgn_channel = comm.AWGNChannel('NoiseMethod', 'Variance', 'VarianceSource', 'Input port');
%%% Initializing Channel Models

%%% Initializing encoder and decoder based on coding rate
ldpc_encoder = comm.LDPCEncoder(dvbs2ldpc(coding_rate));
ldpc_decoder = comm.LDPCDecoder(dvbs2ldpc(coding_rate));
ldpc_config = ldpcEncoderConfig(dvbs2ldpc(coding_rate));
ldpc_num_bits = ldpc_config.NumInformationBits;
%%% Initializing encoder and decoder based on coding rate

%%% Initializing parameters for 24 bit Cyclic Redundancy Check (CRC) error detection
crc_24_generator = comm.CRCGenerator('Polynomial',[1 1 zeros(1, 16) 1 1 0 0 0 1 1]);
crc_bit = 24;
crc_24_detector = comm.CRCDetector('Polynomial',[1 1 zeros(1, 16) 1 1 0 0 0 1 1]);
%%% Initializing parameters for 24 bit Cyclic Redundancy Check (CRC) error detection


number_of_bits_per_frame = (((number_of_resource_block * number_of_data_subcarrier * number_of_symbol_per_subcarrier * number_of_bits_per_symbol * number_of_transmit_antenna)) ...
        * coding_rate) - crc_bit; %% Initializing number of bits per frame
