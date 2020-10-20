//
//  Parula.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 10/19/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreGraphics

struct Parula256 {
    static let colors = [CGColor(red: 0.2081, green: 0.1663, blue: 0.5292, alpha: 1.0),
                  CGColor(red: 0.2091, green: 0.1721, blue: 0.5411, alpha: 1.0),
                  CGColor(red: 0.2101, green: 0.1779, blue: 0.5530, alpha: 1.0),
                  CGColor(red: 0.2109, green: 0.1837, blue: 0.5650, alpha: 1.0),
                  CGColor(red: 0.2116, green: 0.1895, blue: 0.5771, alpha: 1.0),
                  CGColor(red: 0.2121, green: 0.1954, blue: 0.5892, alpha: 1.0),
                  CGColor(red: 0.2124, green: 0.2013, blue: 0.6013, alpha: 1.0),
                  CGColor(red: 0.2125, green: 0.2072, blue: 0.6135, alpha: 1.0),
                  CGColor(red: 0.2123, green: 0.2132, blue: 0.6258, alpha: 1.0),
                  CGColor(red: 0.2118, green: 0.2192, blue: 0.6381, alpha: 1.0),
                  CGColor(red: 0.2111, green: 0.2253, blue: 0.6505, alpha: 1.0),
                  CGColor(red: 0.2099, green: 0.2315, blue: 0.6629, alpha: 1.0),
                  CGColor(red: 0.2084, green: 0.2377, blue: 0.6753, alpha: 1.0),
                  CGColor(red: 0.2063, green: 0.2440, blue: 0.6878, alpha: 1.0),
                  CGColor(red: 0.2038, green: 0.2503, blue: 0.7003, alpha: 1.0),
                  CGColor(red: 0.2006, green: 0.2568, blue: 0.7129, alpha: 1.0),
                  CGColor(red: 0.1968, green: 0.2632, blue: 0.7255, alpha: 1.0),
                  CGColor(red: 0.1921, green: 0.2698, blue: 0.7381, alpha: 1.0),
                  CGColor(red: 0.1867, green: 0.2764, blue: 0.7507, alpha: 1.0),
                  CGColor(red: 0.1802, green: 0.2832, blue: 0.7634, alpha: 1.0),
                  CGColor(red: 0.1728, green: 0.2902, blue: 0.7762, alpha: 1.0),
                  CGColor(red: 0.1641, green: 0.2975, blue: 0.7890, alpha: 1.0),
                  CGColor(red: 0.1541, green: 0.3052, blue: 0.8017, alpha: 1.0),
                  CGColor(red: 0.1427, green: 0.3132, blue: 0.8145, alpha: 1.0),
                  CGColor(red: 0.1295, green: 0.3217, blue: 0.8269, alpha: 1.0),
                  CGColor(red: 0.1147, green: 0.3306, blue: 0.8387, alpha: 1.0),
                  CGColor(red: 0.0986, green: 0.3397, blue: 0.8495, alpha: 1.0),
                  CGColor(red: 0.0816, green: 0.3486, blue: 0.8588, alpha: 1.0),
                  CGColor(red: 0.0646, green: 0.3572, blue: 0.8664, alpha: 1.0),
                  CGColor(red: 0.0482, green: 0.3651, blue: 0.8722, alpha: 1.0),
                  CGColor(red: 0.0329, green: 0.3724, blue: 0.8765, alpha: 1.0),
                  CGColor(red: 0.0213, green: 0.3792, blue: 0.8796, alpha: 1.0),
                  CGColor(red: 0.0136, green: 0.3853, blue: 0.8815, alpha: 1.0),
                  CGColor(red: 0.0086, green: 0.3911, blue: 0.8827, alpha: 1.0),
                  CGColor(red: 0.0060, green: 0.3965, blue: 0.8833, alpha: 1.0),
                  CGColor(red: 0.0051, green: 0.4017, blue: 0.8834, alpha: 1.0),
                  CGColor(red: 0.0054, green: 0.4066, blue: 0.8831, alpha: 1.0),
                  CGColor(red: 0.0067, green: 0.4113, blue: 0.8825, alpha: 1.0),
                  CGColor(red: 0.0089, green: 0.4159, blue: 0.8816, alpha: 1.0),
                  CGColor(red: 0.0116, green: 0.4203, blue: 0.8805, alpha: 1.0),
                  CGColor(red: 0.0148, green: 0.4246, blue: 0.8793, alpha: 1.0),
                  CGColor(red: 0.0184, green: 0.4288, blue: 0.8779, alpha: 1.0),
                  CGColor(red: 0.0223, green: 0.4329, blue: 0.8763, alpha: 1.0),
                  CGColor(red: 0.0264, green: 0.4370, blue: 0.8747, alpha: 1.0),
                  CGColor(red: 0.0306, green: 0.4410, blue: 0.8729, alpha: 1.0),
                  CGColor(red: 0.0349, green: 0.4449, blue: 0.8711, alpha: 1.0),
                  CGColor(red: 0.0394, green: 0.4488, blue: 0.8692, alpha: 1.0),
                  CGColor(red: 0.0437, green: 0.4526, blue: 0.8672, alpha: 1.0),
                  CGColor(red: 0.0477, green: 0.4564, blue: 0.8652, alpha: 1.0),
                  CGColor(red: 0.0514, green: 0.4602, blue: 0.8632, alpha: 1.0),
                  CGColor(red: 0.0549, green: 0.4640, blue: 0.8611, alpha: 1.0),
                  CGColor(red: 0.0582, green: 0.4677, blue: 0.8589, alpha: 1.0),
                  CGColor(red: 0.0612, green: 0.4714, blue: 0.8568, alpha: 1.0),
                  CGColor(red: 0.0640, green: 0.4751, blue: 0.8546, alpha: 1.0),
                  CGColor(red: 0.0666, green: 0.4788, blue: 0.8525, alpha: 1.0),
                  CGColor(red: 0.0689, green: 0.4825, blue: 0.8503, alpha: 1.0),
                  CGColor(red: 0.0710, green: 0.4862, blue: 0.8481, alpha: 1.0),
                  CGColor(red: 0.0729, green: 0.4899, blue: 0.8460, alpha: 1.0),
                  CGColor(red: 0.0746, green: 0.4937, blue: 0.8439, alpha: 1.0),
                  CGColor(red: 0.0761, green: 0.4974, blue: 0.8418, alpha: 1.0),
                  CGColor(red: 0.0773, green: 0.5012, blue: 0.8398, alpha: 1.0),
                  CGColor(red: 0.0782, green: 0.5051, blue: 0.8378, alpha: 1.0),
                  CGColor(red: 0.0789, green: 0.5089, blue: 0.8359, alpha: 1.0),
                  CGColor(red: 0.0794, green: 0.5129, blue: 0.8341, alpha: 1.0),
                  CGColor(red: 0.0795, green: 0.5169, blue: 0.8324, alpha: 1.0),
                  CGColor(red: 0.0793, green: 0.5210, blue: 0.8308, alpha: 1.0),
                  CGColor(red: 0.0788, green: 0.5251, blue: 0.8293, alpha: 1.0),
                  CGColor(red: 0.0778, green: 0.5295, blue: 0.8280, alpha: 1.0),
                  CGColor(red: 0.0764, green: 0.5339, blue: 0.8270, alpha: 1.0),
                  CGColor(red: 0.0746, green: 0.5384, blue: 0.8261, alpha: 1.0),
                  CGColor(red: 0.0724, green: 0.5431, blue: 0.8253, alpha: 1.0),
                  CGColor(red: 0.0698, green: 0.5479, blue: 0.8247, alpha: 1.0),
                  CGColor(red: 0.0668, green: 0.5527, blue: 0.8243, alpha: 1.0),
                  CGColor(red: 0.0636, green: 0.5577, blue: 0.8239, alpha: 1.0),
                  CGColor(red: 0.0600, green: 0.5627, blue: 0.8237, alpha: 1.0),
                  CGColor(red: 0.0562, green: 0.5677, blue: 0.8234, alpha: 1.0),
                  CGColor(red: 0.0523, green: 0.5727, blue: 0.8231, alpha: 1.0),
                  CGColor(red: 0.0484, green: 0.5777, blue: 0.8228, alpha: 1.0),
                  CGColor(red: 0.0445, green: 0.5826, blue: 0.8223, alpha: 1.0),
                  CGColor(red: 0.0408, green: 0.5874, blue: 0.8217, alpha: 1.0),
                  CGColor(red: 0.0372, green: 0.5922, blue: 0.8209, alpha: 1.0),
                  CGColor(red: 0.0342, green: 0.5968, blue: 0.8198, alpha: 1.0),
                  CGColor(red: 0.0317, green: 0.6012, blue: 0.8186, alpha: 1.0),
                  CGColor(red: 0.0296, green: 0.6055, blue: 0.8171, alpha: 1.0),
                  CGColor(red: 0.0279, green: 0.6097, blue: 0.8154, alpha: 1.0),
                  CGColor(red: 0.0265, green: 0.6137, blue: 0.8135, alpha: 1.0),
                  CGColor(red: 0.0255, green: 0.6176, blue: 0.8114, alpha: 1.0),
                  CGColor(red: 0.0248, green: 0.6214, blue: 0.8091, alpha: 1.0),
                  CGColor(red: 0.0243, green: 0.6250, blue: 0.8066, alpha: 1.0),
                  CGColor(red: 0.0239, green: 0.6285, blue: 0.8039, alpha: 1.0),
                  CGColor(red: 0.0237, green: 0.6319, blue: 0.8010, alpha: 1.0),
                  CGColor(red: 0.0235, green: 0.6352, blue: 0.7980, alpha: 1.0),
                  CGColor(red: 0.0233, green: 0.6384, blue: 0.7948, alpha: 1.0),
                  CGColor(red: 0.0231, green: 0.6415, blue: 0.7916, alpha: 1.0),
                  CGColor(red: 0.0230, green: 0.6445, blue: 0.7881, alpha: 1.0),
                  CGColor(red: 0.0229, green: 0.6474, blue: 0.7846, alpha: 1.0),
                  CGColor(red: 0.0227, green: 0.6503, blue: 0.7810, alpha: 1.0),
                  CGColor(red: 0.0227, green: 0.6531, blue: 0.7773, alpha: 1.0),
                  CGColor(red: 0.0232, green: 0.6558, blue: 0.7735, alpha: 1.0),
                  CGColor(red: 0.0238, green: 0.6585, blue: 0.7696, alpha: 1.0),
                  CGColor(red: 0.0246, green: 0.6611, blue: 0.7656, alpha: 1.0),
                  CGColor(red: 0.0263, green: 0.6637, blue: 0.7615, alpha: 1.0),
                  CGColor(red: 0.0282, green: 0.6663, blue: 0.7574, alpha: 1.0),
                  CGColor(red: 0.0306, green: 0.6688, blue: 0.7532, alpha: 1.0),
                  CGColor(red: 0.0338, green: 0.6712, blue: 0.7490, alpha: 1.0),
                  CGColor(red: 0.0373, green: 0.6737, blue: 0.7446, alpha: 1.0),
                  CGColor(red: 0.0418, green: 0.6761, blue: 0.7402, alpha: 1.0),
                  CGColor(red: 0.0467, green: 0.6784, blue: 0.7358, alpha: 1.0),
                  CGColor(red: 0.0516, green: 0.6808, blue: 0.7313, alpha: 1.0),
                  CGColor(red: 0.0574, green: 0.6831, blue: 0.7267, alpha: 1.0),
                  CGColor(red: 0.0629, green: 0.6854, blue: 0.7221, alpha: 1.0),
                  CGColor(red: 0.0692, green: 0.6877, blue: 0.7173, alpha: 1.0),
                  CGColor(red: 0.0755, green: 0.6899, blue: 0.7126, alpha: 1.0),
                  CGColor(red: 0.0820, green: 0.6921, blue: 0.7078, alpha: 1.0),
                  CGColor(red: 0.0889, green: 0.6943, blue: 0.7029, alpha: 1.0),
                  CGColor(red: 0.0956, green: 0.6965, blue: 0.6979, alpha: 1.0),
                  CGColor(red: 0.1031, green: 0.6986, blue: 0.6929, alpha: 1.0),
                  CGColor(red: 0.1104, green: 0.7007, blue: 0.6878, alpha: 1.0),
                  CGColor(red: 0.1180, green: 0.7028, blue: 0.6827, alpha: 1.0),
                  CGColor(red: 0.1258, green: 0.7049, blue: 0.6775, alpha: 1.0),
                  CGColor(red: 0.1335, green: 0.7069, blue: 0.6723, alpha: 1.0),
                  CGColor(red: 0.1418, green: 0.7089, blue: 0.6669, alpha: 1.0),
                  CGColor(red: 0.1499, green: 0.7109, blue: 0.6616, alpha: 1.0),
                  CGColor(red: 0.1585, green: 0.7129, blue: 0.6561, alpha: 1.0),
                  CGColor(red: 0.1671, green: 0.7148, blue: 0.6507, alpha: 1.0),
                  CGColor(red: 0.1758, green: 0.7168, blue: 0.6451, alpha: 1.0),
                  CGColor(red: 0.1849, green: 0.7186, blue: 0.6395, alpha: 1.0),
                  CGColor(red: 0.1938, green: 0.7205, blue: 0.6338, alpha: 1.0),
                  CGColor(red: 0.2033, green: 0.7223, blue: 0.6281, alpha: 1.0),
                  CGColor(red: 0.2128, green: 0.7241, blue: 0.6223, alpha: 1.0),
                  CGColor(red: 0.2224, green: 0.7259, blue: 0.6165, alpha: 1.0),
                  CGColor(red: 0.2324, green: 0.7275, blue: 0.6107, alpha: 1.0),
                  CGColor(red: 0.2423, green: 0.7292, blue: 0.6048, alpha: 1.0),
                  CGColor(red: 0.2527, green: 0.7308, blue: 0.5988, alpha: 1.0),
                  CGColor(red: 0.2631, green: 0.7324, blue: 0.5929, alpha: 1.0),
                  CGColor(red: 0.2735, green: 0.7339, blue: 0.5869, alpha: 1.0),
                  CGColor(red: 0.2845, green: 0.7354, blue: 0.5809, alpha: 1.0),
                  CGColor(red: 0.2953, green: 0.7368, blue: 0.5749, alpha: 1.0),
                  CGColor(red: 0.3064, green: 0.7381, blue: 0.5689, alpha: 1.0),
                  CGColor(red: 0.3177, green: 0.7394, blue: 0.5630, alpha: 1.0),
                  CGColor(red: 0.3289, green: 0.7406, blue: 0.5570, alpha: 1.0),
                  CGColor(red: 0.3405, green: 0.7417, blue: 0.5512, alpha: 1.0),
                  CGColor(red: 0.3520, green: 0.7428, blue: 0.5453, alpha: 1.0),
                  CGColor(red: 0.3635, green: 0.7438, blue: 0.5396, alpha: 1.0),
                  CGColor(red: 0.3753, green: 0.7446, blue: 0.5339, alpha: 1.0),
                  CGColor(red: 0.3869, green: 0.7454, blue: 0.5283, alpha: 1.0),
                  CGColor(red: 0.3986, green: 0.7461, blue: 0.5229, alpha: 1.0),
                  CGColor(red: 0.4103, green: 0.7467, blue: 0.5175, alpha: 1.0),
                  CGColor(red: 0.4218, green: 0.7473, blue: 0.5123, alpha: 1.0),
                  CGColor(red: 0.4334, green: 0.7477, blue: 0.5072, alpha: 1.0),
                  CGColor(red: 0.4447, green: 0.7482, blue: 0.5021, alpha: 1.0),
                  CGColor(red: 0.4561, green: 0.7485, blue: 0.4972, alpha: 1.0),
                  CGColor(red: 0.4672, green: 0.7487, blue: 0.4924, alpha: 1.0),
                  CGColor(red: 0.4783, green: 0.7489, blue: 0.4877, alpha: 1.0),
                  CGColor(red: 0.4892, green: 0.7491, blue: 0.4831, alpha: 1.0),
                  CGColor(red: 0.5000, green: 0.7491, blue: 0.4786, alpha: 1.0),
                  CGColor(red: 0.5106, green: 0.7492, blue: 0.4741, alpha: 1.0),
                  CGColor(red: 0.5212, green: 0.7492, blue: 0.4698, alpha: 1.0),
                  CGColor(red: 0.5315, green: 0.7491, blue: 0.4655, alpha: 1.0),
                  CGColor(red: 0.5418, green: 0.7490, blue: 0.4613, alpha: 1.0),
                  CGColor(red: 0.5519, green: 0.7489, blue: 0.4571, alpha: 1.0),
                  CGColor(red: 0.5619, green: 0.7487, blue: 0.4531, alpha: 1.0),
                  CGColor(red: 0.5718, green: 0.7485, blue: 0.4490, alpha: 1.0),
                  CGColor(red: 0.5816, green: 0.7482, blue: 0.4451, alpha: 1.0),
                  CGColor(red: 0.5913, green: 0.7479, blue: 0.4412, alpha: 1.0),
                  CGColor(red: 0.6009, green: 0.7476, blue: 0.4374, alpha: 1.0),
                  CGColor(red: 0.6103, green: 0.7473, blue: 0.4335, alpha: 1.0),
                  CGColor(red: 0.6197, green: 0.7469, blue: 0.4298, alpha: 1.0),
                  CGColor(red: 0.6290, green: 0.7465, blue: 0.4261, alpha: 1.0),
                  CGColor(red: 0.6382, green: 0.7460, blue: 0.4224, alpha: 1.0),
                  CGColor(red: 0.6473, green: 0.7456, blue: 0.4188, alpha: 1.0),
                  CGColor(red: 0.6564, green: 0.7451, blue: 0.4152, alpha: 1.0),
                  CGColor(red: 0.6653, green: 0.7446, blue: 0.4116, alpha: 1.0),
                  CGColor(red: 0.6742, green: 0.7441, blue: 0.4081, alpha: 1.0),
                  CGColor(red: 0.6830, green: 0.7435, blue: 0.4046, alpha: 1.0),
                  CGColor(red: 0.6918, green: 0.7430, blue: 0.4011, alpha: 1.0),
                  CGColor(red: 0.7004, green: 0.7424, blue: 0.3976, alpha: 1.0),
                  CGColor(red: 0.7091, green: 0.7418, blue: 0.3942, alpha: 1.0),
                  CGColor(red: 0.7176, green: 0.7412, blue: 0.3908, alpha: 1.0),
                  CGColor(red: 0.7261, green: 0.7405, blue: 0.3874, alpha: 1.0),
                  CGColor(red: 0.7346, green: 0.7399, blue: 0.3840, alpha: 1.0),
                  CGColor(red: 0.7430, green: 0.7392, blue: 0.3806, alpha: 1.0),
                  CGColor(red: 0.7513, green: 0.7385, blue: 0.3773, alpha: 1.0),
                  CGColor(red: 0.7596, green: 0.7378, blue: 0.3739, alpha: 1.0),
                  CGColor(red: 0.7679, green: 0.7372, blue: 0.3706, alpha: 1.0),
                  CGColor(red: 0.7761, green: 0.7364, blue: 0.3673, alpha: 1.0),
                  CGColor(red: 0.7843, green: 0.7357, blue: 0.3639, alpha: 1.0),
                  CGColor(red: 0.7924, green: 0.7350, blue: 0.3606, alpha: 1.0),
                  CGColor(red: 0.8005, green: 0.7343, blue: 0.3573, alpha: 1.0),
                  CGColor(red: 0.8085, green: 0.7336, blue: 0.3539, alpha: 1.0),
                  CGColor(red: 0.8166, green: 0.7329, blue: 0.3506, alpha: 1.0),
                  CGColor(red: 0.8246, green: 0.7322, blue: 0.3472, alpha: 1.0),
                  CGColor(red: 0.8325, green: 0.7315, blue: 0.3438, alpha: 1.0),
                  CGColor(red: 0.8405, green: 0.7308, blue: 0.3404, alpha: 1.0),
                  CGColor(red: 0.8484, green: 0.7301, blue: 0.3370, alpha: 1.0),
                  CGColor(red: 0.8563, green: 0.7294, blue: 0.3336, alpha: 1.0),
                  CGColor(red: 0.8642, green: 0.7288, blue: 0.3300, alpha: 1.0),
                  CGColor(red: 0.8720, green: 0.7282, blue: 0.3265, alpha: 1.0),
                  CGColor(red: 0.8798, green: 0.7276, blue: 0.3229, alpha: 1.0),
                  CGColor(red: 0.8877, green: 0.7271, blue: 0.3193, alpha: 1.0),
                  CGColor(red: 0.8954, green: 0.7266, blue: 0.3156, alpha: 1.0),
                  CGColor(red: 0.9032, green: 0.7262, blue: 0.3117, alpha: 1.0),
                  CGColor(red: 0.9110, green: 0.7259, blue: 0.3078, alpha: 1.0),
                  CGColor(red: 0.9187, green: 0.7256, blue: 0.3038, alpha: 1.0),
                  CGColor(red: 0.9264, green: 0.7256, blue: 0.2996, alpha: 1.0),
                  CGColor(red: 0.9341, green: 0.7256, blue: 0.2953, alpha: 1.0),
                  CGColor(red: 0.9417, green: 0.7259, blue: 0.2907, alpha: 1.0),
                  CGColor(red: 0.9493, green: 0.7264, blue: 0.2859, alpha: 1.0),
                  CGColor(red: 0.9567, green: 0.7273, blue: 0.2808, alpha: 1.0),
                  CGColor(red: 0.9639, green: 0.7285, blue: 0.2754, alpha: 1.0),
                  CGColor(red: 0.9708, green: 0.7303, blue: 0.2696, alpha: 1.0),
                  CGColor(red: 0.9773, green: 0.7326, blue: 0.2634, alpha: 1.0),
                  CGColor(red: 0.9831, green: 0.7355, blue: 0.2570, alpha: 1.0),
                  CGColor(red: 0.9882, green: 0.7390, blue: 0.2504, alpha: 1.0),
                  CGColor(red: 0.9922, green: 0.7431, blue: 0.2437, alpha: 1.0),
                  CGColor(red: 0.9952, green: 0.7476, blue: 0.2373, alpha: 1.0),
                  CGColor(red: 0.9973, green: 0.7524, blue: 0.2310, alpha: 1.0),
                  CGColor(red: 0.9986, green: 0.7573, blue: 0.2251, alpha: 1.0),
                  CGColor(red: 0.9991, green: 0.7624, blue: 0.2195, alpha: 1.0),
                  CGColor(red: 0.9990, green: 0.7675, blue: 0.2141, alpha: 1.0),
                  CGColor(red: 0.9985, green: 0.7726, blue: 0.2090, alpha: 1.0),
                  CGColor(red: 0.9976, green: 0.7778, blue: 0.2042, alpha: 1.0),
                  CGColor(red: 0.9964, green: 0.7829, blue: 0.1995, alpha: 1.0),
                  CGColor(red: 0.9950, green: 0.7880, blue: 0.1949, alpha: 1.0),
                  CGColor(red: 0.9933, green: 0.7931, blue: 0.1905, alpha: 1.0),
                  CGColor(red: 0.9914, green: 0.7981, blue: 0.1863, alpha: 1.0),
                  CGColor(red: 0.9894, green: 0.8032, blue: 0.1821, alpha: 1.0),
                  CGColor(red: 0.9873, green: 0.8083, blue: 0.1780, alpha: 1.0),
                  CGColor(red: 0.9851, green: 0.8133, blue: 0.1740, alpha: 1.0),
                  CGColor(red: 0.9828, green: 0.8184, blue: 0.1700, alpha: 1.0),
                  CGColor(red: 0.9805, green: 0.8235, blue: 0.1661, alpha: 1.0),
                  CGColor(red: 0.9782, green: 0.8286, blue: 0.1622, alpha: 1.0),
                  CGColor(red: 0.9759, green: 0.8337, blue: 0.1583, alpha: 1.0),
                  CGColor(red: 0.9736, green: 0.8389, blue: 0.1544, alpha: 1.0),
                  CGColor(red: 0.9713, green: 0.8441, blue: 0.1505, alpha: 1.0),
                  CGColor(red: 0.9692, green: 0.8494, blue: 0.1465, alpha: 1.0),
                  CGColor(red: 0.9672, green: 0.8548, blue: 0.1425, alpha: 1.0),
                  CGColor(red: 0.9654, green: 0.8603, blue: 0.1385, alpha: 1.0),
                  CGColor(red: 0.9638, green: 0.8659, blue: 0.1343, alpha: 1.0),
                  CGColor(red: 0.9623, green: 0.8716, blue: 0.1301, alpha: 1.0),
                  CGColor(red: 0.9611, green: 0.8774, blue: 0.1258, alpha: 1.0),
                  CGColor(red: 0.9600, green: 0.8834, blue: 0.1215, alpha: 1.0),
                  CGColor(red: 0.9593, green: 0.8895, blue: 0.1171, alpha: 1.0),
                  CGColor(red: 0.9588, green: 0.8958, blue: 0.1126, alpha: 1.0),
                  CGColor(red: 0.9586, green: 0.9022, blue: 0.1082, alpha: 1.0),
                  CGColor(red: 0.9587, green: 0.9088, blue: 0.1036, alpha: 1.0),
                  CGColor(red: 0.9591, green: 0.9155, blue: 0.0990, alpha: 1.0),
                  CGColor(red: 0.9599, green: 0.9225, blue: 0.0944, alpha: 1.0),
                  CGColor(red: 0.9610, green: 0.9296, blue: 0.0897, alpha: 1.0),
                  CGColor(red: 0.9624, green: 0.9368, blue: 0.0850, alpha: 1.0),
                  CGColor(red: 0.9641, green: 0.9443, blue: 0.0802, alpha: 1.0),
                  CGColor(red: 0.9662, green: 0.9518, blue: 0.0753, alpha: 1.0),
                  CGColor(red: 0.9685, green: 0.9595, blue: 0.0703, alpha: 1.0),
                  CGColor(red: 0.9710, green: 0.9673, blue: 0.0651, alpha: 1.0),
                  CGColor(red: 0.9736, green: 0.9752, blue: 0.0597, alpha: 1.0),
                  CGColor(red: 0.9763, green: 0.9831, blue: 0.0538, alpha: 1.0)]
    
    static func get(_ value: UInt8) -> CGColor? {
        return colors[Int(value)]
    }
}
