# wearables-for-gait-synchronized-smartphone-imu-and-walkway-data

## Wearables for gait: Synchronized smartphone IMU and walkway data during normal gait and obstacle avoidance gait 

Nyman, Edward; Watkinson, Sophia; Patwardhan Shriniwas; Kontson, Kimberly 

### Abstract: 
A PhysioNet database consisting of time-synchronized raw smartphone IMU, reference (ground truth) IMU, and pressure-sensing walkway data collected during normal gait and obstacle avoidance gait with two different smartphones placed at varying positions and orientations on the body was published.  This DBP GitHub repository was established to house the MATLAB code utilized to synchronize multiple system separate inputs that comprise said dataset. In addition, all raw data are included in a zipped folder. This repository may also serve to house links to any relevant future publications by this working group relative to said effort.  

The dataset, as collected, and housed within the linked PhysioNet database contains 400 files representing 20 healthy participants x 2 smartphone placements x 5 smartphone orientations x 2 gait trial types. However, due to data loss for some matched signals, 20 trials were discarded, leaving a total of 380 trials remaining in the final dataset. All IMU sensors and the walkway collected data at 100 Hz. This repository is intended for use in evaluating the effect of smartphone positioning on resultant IMU data relative to a ground truth reference IMU system and walkway data and can also be utilized for other gait algorithm development and validation purposes.
 
### Background:
Many wearable devices are intended to be used by the general population or patients outside of a clinical environment, but the ability of the patient/user to correctly place the devices on the body has not been thoroughly evaluated and the variability introduced by incorrect placement of different types of smart devices capturing movement is not well characterized [1,2].  An understanding of how different device (IMU) positions on the body and different types of smartphones impact the accuracy and reliability of the device output is necessary to adequately evaluate wearable technology [3,4,5]. This dataset can be utilized to elucidate the effect of smartphone positioning on resultant smartphone IMU data relative to a ground truth IMU system and walkway data.  In addition, the data provided can be utilized for other gait algorithm development and validation purposes.
 
### Methods & Technical Implementation:
Self-selected-pace walking gait data were collected and stored for 20 human volunteer participants while performing repeated trials of two gait tasks (normal walking gait for four consecutive passes across 16’ walkway followed by obstacle avoidance gait for four consecutive passes) in a controlled laboratory environment and walking across a flat surface. For obstacles, four short boxes were placed along the walkway to avoid during walking and participants were instructed to walk around the boxes to elicit a serpentine walking pattern. A brief quasi-static 10-20 second pause in walking separates each gait task for each trial.  Smartphone IMU data were collected using the cross-platform Sensor Logger mobile application [5].  Sampling rate was held consistent for all sensors at 100Hz.  Two different phone types (iPhone and Android) were placed at one of two locations on the body in a series of different orientations (0, 45, 90, 135, and 180 degrees).  Note that 0 degrees represented a vertical alignment, 90 degrees a horizontal alignment, and 180 degrees an inverted alignment. Two different smartphone and reference IMU sensor pair locations were located either on the lower back (with orientation rotation in the frontal plane) or on the right lateral thigh (with orientation rotation approximating the sagittal plane).  For any given trial, when one type of smartphone was located on the lower back, the other smartphone type was located on the thigh. Smartphone locations were then swapped such that each smartphone and orientation location was tested. Raw time-synced datasets were stored in separate csv files for each participant resulting in a total of 400 files (20 participants x 5 orientations x 2 smartphone locations x 2 gait tasks). 

Data for each of two reference IMUs and one walkway were post-collection time-synced to smartphone IMU data by time-matching the highest peak of the total acceleration signal for an intentionally generated high impulse event occurring at the beginning of each trial across IMUs using the MATLAB code script included in this repository.   MATLAB code is provided as single .m file. Code can be run by ensuring data folders (raw data) are consistent with conventions outlined in code. Code was generated and tested using MATLAB R2022B and requires no additional toolbox support.

### Content Description:  

### Current:

- Sync_All_Data.m                    MATLAB code for multiple system sync (alignment)

- SAMPLERAWDATA.zip                  Zipped folder containing a representative sample (single participant and single orientaton - 0 degrees) of raw data collected.

- RAWDATA.zip	                       Zipped folder containing all raw data collected  *Raw data folder is large. Full raw dataset coming soon.*

- www.physionet.org/XXXXX            Link to PhysioNet.org repository with all data **Currently pending review and approval**


### Future:

- Links to any papers published by this group relative to this project may be added.


### Usage notes: 
All data provided may be reused for any reasonable purpose, however, please note that these data are provided 'as is' and no guarantees are offered.   A separate PhysioNet (physionet.org) repository is maintained with full dataset available to qualified users. Please note: The mention of commercial products, their sources, or their use in connection with material reported herein is not to be construed as either an actual or implied endorsement of such products by the Department of Health and Human Services.

### Ethics: 
All data were collected from human subjects during a study approved by the U.S. Food and Drug Administration Institutional Review Board and in accordance with provisions consistent with the Declaration of Helsinki. Thorough measures were taken to de-identify data.  
  
### Acknowledgments:  
We thank all study participants. This study was funded by the United States Food & Drug Administration's Critical Path initiative and Division of Biomedical Physics base funding.
 
### Conflicts of Interest: 
The author(s) have no conflicts of interest to declare.
