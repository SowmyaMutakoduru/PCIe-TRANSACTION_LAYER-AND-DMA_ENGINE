# PCIe-TRANSACTION-LAYER-AND-DMA-ENGINE  
# OVERVIEW  
The design focuses on generating and managing Transaction Layer Packets (TLP’s) following PCIe protocol specifications. It enables seamless and reliable data movement between peripherals, providing features essential for high-throughput applications that rely on robust transaction management. Developed a UVM-based verification environment with the Root Complex, CPU, BAR and switch modelled as a testbench, enabling comprehensive protocol checks and assertion-based verification to ensure PCIe compliance and robustness.  

# FEATURES

1. **PCIe-Compliant Transaction Layer**  
•	Implements the Transaction Layer Packet (TLP) format as per the PCI Express Base Specification.  
•	Supports packet types including Memory Read/Write  
•	Handles Header formation, Tag assignment, Requester/Completer IDs, and Length fields correctly.  
2. **DMA Engine for High-Speed Data Movement**  
•	Designed to autonomously transfer blocks of data between memory and peripheral devices without CPU intervention.  
•	Incorporates doorbell based and descriptor-based transfer management, allowing flexible source and destination address configurations.  
•	Include address incrementing, burst support, and transfer completion signaling.  
•	Capable of generating TLP requests dynamically based on DMA descriptors.

# WORKING  
Workflow Between Transaction Layer and DMA Engine (Endpoint Side)  
1. **Descriptor Fetch via Doorbell Mechanism**
•	The testbench acts as the Root Complex model and sends doorbell writes (Memory Write TLPs) directly to the doorbell register within the endpoint.  
•	This doorbell TLP acts as a trigger signal, informing the DMA Engine that a new descriptor is available in the memory region.  
•	The descriptor contains information such as Source Address, Destination Address, Transfer Length, and Control Bits.  
•	The Transaction Layer receives this doorbell write, forwards it to the DMA Engine, and acts as a local packet router.  
2. **Descriptor Read and DMA Setup**  
•	Upon receiving the doorbell write, the DMA Engine reads the descriptor through internal register or memory addressing inside the endpoint.  
•	Since the TLPs are generated from the testbench, the DMA doesn’t issue external PCIe reads; instead, the testbench feeds pre-crafted PCIe TLPs mimicking Root Complex behaviour.  
•	The DMA decodes the descriptor and prepares internal transfer command structures using the fetched parameters.  
3. **Communication Between TL and DMA**  
•	The Transaction Layer and DMA Engine communicate through internal axi-stream, exchanging payloads and control information.  
•	The DMA Engine generates internal read or write commands in axi-stream format, which the TL converts to corresponding Memory Read/Write Request TLPs if required.  
•	These TLPs are already provided by the testbench, so TL acts primarily as a packet receiver, parser, and forwarder to the DMA.  
4. **Data Transfer and Completion**  
•	The DMA Engine performs the local data move operation between the source and destination buffers within the endpoint domain.  
•	For verification, the testbench injects Completion TLPs that represent the PCIe host responding to pending requests.  
•	The Transaction Layer matches each Completion TLP with active tags or descriptor IDs and confirms completion to the DMA module.  
5. **Status and Interrupt Handling**  
•	The DMA Engine updates its internal descriptor status after each transfer.   
•	It triggers a Completion Signal internally within an endpoint when the transfer is completed.  
•	Verification monitors in the UVM testbench validate the TL-DMA handshake signals and ensure all protocol-level and functional timing constraints are satisfied.

 # WORKING OF TRASACTION LAYER  
 <img width="500" height="500" alt="Beige Minimal Flowchart Infographic Graph (2)" src="https://github.com/user-attachments/assets/75ff5649-71f1-4323-87b9-996caef07dd7" />

 # WORKING OF DMA ENGINE  
 <img width="500" height="500" alt="Beige Minimal Flowchart Infographic Graph (3)" src="https://github.com/user-attachments/assets/6547fac8-8759-416f-9b12-965ff84f197b" />  

 # WAVEFORM  
 <img width="940" height="392" alt="image" src="https://github.com/user-attachments/assets/1492dc1b-343f-4250-80f4-256b3663b277" />

 





