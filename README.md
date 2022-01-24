# LDPC and MIMO in Vehicular Communication
This project demonstrates how Low Density Parity Check (LDPC) Code and Multiple Input Multiple Output (MIMO) can be employed in Vehicular Communication. The simulation flow of this project is expressed with the block diagram below.

![MIMO and LDPC Coding in DSRC](https://user-images.githubusercontent.com/3108754/150695696-ddeebfc1-2100-4c1a-8df5-d48aa4d753a4.JPG)

The above figure depicts the structure of the DSRC PHY layer including LDPC and MIMO functionality. According to this figure data produced by the sending device is pushed to the PHY layer. The PHY layer prepares the data to be transmitted through the air medium. There are several steps in the PHY layer at the transmitter side which are FEC Coding, Signal Modulation, OFDM Modulation, and MIMO Transmitter. The FEC Coding portion converts the data bits into codeword bits using a specified coding scheme and coding rate. This project uses LDPC Coding shceme and two coding rates are available which are 1/3 and 1/2. Then the coded data is passed through the Signal Modulation portion where the codeword bits are modulated using a specified modulation technique. This project uses QPSK modulation technique. After that, the modulated data is passed through the OFDM Modulation step where modulated data symbols are prepared to combat against interference caused by multipath fading in the air medium. OFDM Modulation and Demodulation segments are configured based on IEEE 802.11p specifications. Then, the OFDM modulated data symbols are sent through the 10 MHz channel using MIMO. This project uses two MIMO configurations which are 2x2 (two transmitting antennas and two receiving antennas) configuration and 4x4 (four transmitting antennas and four receiving antennas) configuration. MIMO Receiver block uses  Minimum Mean Squared Error (MMSE) equalization method. On the receiver side, similar demodulation and decoding techniques are applied to the received data to get the best approximation of the transmitted data. The simulation results are evaluated based on two metrics which are Bit Error Rate (BER) and Throughput.

Associated files-->

* Experimental_Simulation.m -> Runs the simulation as a complete package
* System_Parameter.m -> Defines the simulation parameters
* System_Initialize.m -> Initializes the simulation objects and necessary variables
* LDPC_and_MIMOinDSRC -> Contains the simulations steps shown in the above figure
* Pilot_Generator.m -> Generates pilot symbols
* Ideal_Channel_Estimation.m -> Measures channel response for equalization purpose
* MMSE_Equalize.m -> Contains implementation for MMSE equalization

N.B.: If you take help from this project, please cite the following papers:
  * U. K. Dey, R. Akl, and R. Chataut, “Throughput Improvement in Vehicular Communication by Using Low Density Parity Check (LDPC),” in The IEEE 12th Annual Computing and Communication Workshop and Conference (CCWC), 2022.
  * U. K. Dey, R. Akl, and R. Chataut, “High Throughput Vehicular Communication Using Spatial Multiplexing MIMO,” in 2020 10th Annual Computing and Communication Workshop and Conference (CCWC), pp. 0110-0115, 2020.
