# -*- encoding : utf-8 -*-
require 'ostruct'
module RosettaStone
  class Country < OpenStruct
    # we found these dialing_codes using these websites:
    #  http://www.countrycodes.com/areacodes/call_britishvirginislands.htm
    #  http://en.wikipedia.org/wiki/List_of_country_calling_codes
    #  http://www.allcountries.eu/togo.htm
    COUNTRIES = [
      new(:iso_code => 4, :translation_key => 'Afghanistan162287802', :country_code=>'AF', :dialing_code => 93, :rworld_parature_id => 2669, :totale_parature_id => 4928),
      new(:iso_code => 248, :translation_key => 'land_Islands267095688', :country_code=>'AX', :dialing_code => 358, :rworld_parature_id => 2670, :totale_parature_id => 4929),
      new(:iso_code => 8, :translation_key => 'Albania274921017', :country_code=>'AL', :dialing_code => 355, :rworld_parature_id => 2671, :totale_parature_id => 4930),
      new(:iso_code => 12, :translation_key => 'Algeria546430239', :country_code=>'DZ', :dialing_code => 213, :rworld_parature_id => 2672, :totale_parature_id => 4931),
      new(:iso_code => 16, :translation_key => 'American_Samoa718387444', :country_code=>'AS', :dialing_code => 1684, :rworld_parature_id => 2470, :totale_parature_id => 4804),
      new(:iso_code => 20, :translation_key => 'Andorra738086208', :country_code=>'AD', :dialing_code => 376, :rworld_parature_id => 2471, :totale_parature_id => 4805),
      new(:iso_code => 24, :translation_key => 'Angola1042912971', :country_code=>'AO', :dialing_code => 244, :rworld_parature_id => 2673, :totale_parature_id => 4932),
      new(:iso_code => 660, :translation_key => 'Anguilla758593494', :country_code=>'AI', :dialing_code => 1264, :rworld_parature_id => 2472, :totale_parature_id => 4806),
      new(:iso_code => 10, :translation_key => 'Antarctica894944817', :country_code=>'AQ', :dialing_code => 672, :rworld_parature_id => 2473, :totale_parature_id => 4807),
      new(:iso_code => 28, :translation_key => 'Antigua_and_Barbuda447223174', :country_code=>'AG', :dialing_code => 1268, :rworld_parature_id => 2474, :totale_parature_id => 4808),
      new(:iso_code => 32, :translation_key => 'Argentina399801906', :country_code=>'AR', :dialing_code => 54, :rworld_parature_id => 2674, :totale_parature_id => 4933),
      new(:iso_code => 51, :translation_key => 'Armenia1006830262', :country_code=>'AM', :dialing_code => 374, :rworld_parature_id => 2475, :totale_parature_id => 4809),
      new(:iso_code => 533, :translation_key => 'Aruba848602329', :country_code=>'AW', :dialing_code => 297, :rworld_parature_id => 2476, :totale_parature_id => 4810),
      new(:iso_code => 36, :translation_key => 'Australia72132524', :country_code=>'AU', :dialing_code => 61, :rworld_parature_id => 2477, :totale_parature_id => 4811),
      new(:iso_code => 40, :translation_key => 'Austria694138778', :country_code=>'AT', :dialing_code => 43, :rworld_parature_id => 2478, :totale_parature_id => 4812),
      new(:iso_code => 31, :translation_key => 'Azerbaijan660595631', :country_code=>'AZ', :dialing_code => 994, :rworld_parature_id => 2675, :totale_parature_id => 4934),
      new(:iso_code => 44, :translation_key => 'Bahamas225711856', :country_code=>'BS', :dialing_code => 1242, :rworld_parature_id => 2479, :totale_parature_id => 4813),
      new(:iso_code => 48, :translation_key => 'Bahrain521131178', :country_code=>'BH', :dialing_code => 973, :rworld_parature_id => 2676, :totale_parature_id => 4935),
      new(:iso_code => 50, :translation_key => 'Bangladesh345883295', :country_code=>'BD', :dialing_code => 880, :rworld_parature_id => 2480, :totale_parature_id => 4814),
      new(:iso_code => 52, :translation_key => 'Barbados487271906', :country_code=>'BB', :dialing_code => 1246, :rworld_parature_id => 2481, :totale_parature_id => 4815),
      new(:iso_code => 112, :translation_key => 'Belarus71772932', :country_code=>'BY', :dialing_code => 375, :rworld_parature_id => 2677, :totale_parature_id => 4936),
      new(:iso_code => 56, :translation_key => 'Belgium118030511', :country_code=>'BE', :dialing_code => 32, :rworld_parature_id => 2482, :totale_parature_id => 4816),
      new(:iso_code => 84, :translation_key => 'Belize611901105', :country_code=>'BZ', :dialing_code => 501, :rworld_parature_id => 2483, :totale_parature_id => 4817),
      new(:iso_code => 204, :translation_key => 'Benin358236730', :country_code=>'BJ', :dialing_code => 229, :rworld_parature_id => 2678, :totale_parature_id => 4937),
      new(:iso_code => 60, :translation_key => 'Bermuda1053283422', :country_code=>'BM', :dialing_code => 1441, :rworld_parature_id => 2484, :totale_parature_id => 4818),
      new(:iso_code => 64, :translation_key => 'Bhutan889595337', :country_code=>'BT', :dialing_code => 975, :rworld_parature_id => 2485, :totale_parature_id => 4819),
      new(:iso_code => 68, :translation_key => 'Bolivia902408492', :country_code=>'BO', :dialing_code => 591, :rworld_parature_id => 2679, :totale_parature_id => 4938),
      new(:iso_code => 70, :translation_key => 'Bosnia_and_Herzegovina210199468', :country_code=>'BA', :dialing_code => 387, :rworld_parature_id => 2680, :totale_parature_id => 4939),
      new(:iso_code => 72, :translation_key => 'Botswana913332413', :country_code=>'BW', :dialing_code => 267, :rworld_parature_id => 2681, :totale_parature_id => 4940),
      new(:iso_code => 76, :translation_key => 'Brazil756605310', :country_code=>'BR', :dialing_code => 55, :rworld_parature_id => 2487, :totale_parature_id => 4820),
      new(:iso_code => 92, :translation_key => 'British_Virgin_Islands847161340', :country_code=>'VG', :dialing_code => 1284, :rworld_parature_id => 2603, :totale_parature_id => 4925),
      new(:iso_code => 96, :translation_key => 'Brunei_Darussalam313074325', :country_code=>'BN', :dialing_code => 673, :rworld_parature_id => 2489, :totale_parature_id => 4821),
      new(:iso_code => 100, :translation_key => 'Bulgaria129480792', :country_code=>'BG', :dialing_code => 359, :rworld_parature_id => 2682, :totale_parature_id => 4941),
      new(:iso_code => 854, :translation_key => 'Burkina_Faso821540617', :country_code=>'BF', :dialing_code => 226, :rworld_parature_id => 2683, :totale_parature_id => 4942),
      new(:iso_code => 108, :translation_key => 'Burundi324971126', :country_code=>'BI', :dialing_code => 257, :rworld_parature_id => 2684, :totale_parature_id => 4943),
      new(:iso_code => 116, :translation_key => 'Cambodia545157164', :country_code=>'KH', :dialing_code => 855, :rworld_parature_id => 2685, :totale_parature_id => 4944),
      new(:iso_code => 120, :translation_key => 'Cameroon3079512', :country_code=>'CM', :dialing_code => 237, :rworld_parature_id => 2686, :totale_parature_id => 4945),
      new(:iso_code => 124, :translation_key => 'Canada906311356', :country_code=>'CA', :dialing_code => 1, :rworld_parature_id => 2490, :totale_parature_id => 4822),
      # FIXME
      #Country.new(:iso_code => , :translation_key => 'Canary_Islands528190698', :country_code=>'', :totale_parature_id => 4946),
      new(:iso_code => 132, :translation_key => 'Cape_Verde351430575', :country_code=>'CV', :dialing_code => 238, :rworld_parature_id => 2688, :totale_parature_id => 4947),
      new(:iso_code => 136, :translation_key => 'Cayman_Islands707412977', :country_code=>'KY', :dialing_code => 1345, :rworld_parature_id => 2491, :totale_parature_id => 4823),
      new(:iso_code => 140, :translation_key => 'Central_African_Republic262711892', :country_code=>'CF', :dialing_code => 236, :rworld_parature_id => 2689, :totale_parature_id => 4948),
      new(:iso_code => 148, :translation_key => 'Chad471398691', :country_code=>'TD', :dialing_code => 235, :rworld_parature_id => 2690, :totale_parature_id => 4949),
      new(:iso_code => 830, :translation_key => 'Channel_Islands843755417', :country_code=>'', :dialing_code => 44, :rworld_parature_id => 2691, :totale_parature_id => 4950),
      new(:iso_code => 152, :translation_key => 'Chile523226422', :country_code=>'CL', :dialing_code => 56, :rworld_parature_id => 2492, :totale_parature_id => 4824),
      new(:iso_code => 156, :translation_key => 'China523091128', :country_code=>'CN', :dialing_code => 86, :rworld_parature_id => 2692, :totale_parature_id => 4951),
      new(:iso_code => 162, :translation_key => 'Christmas_Island753170401', :country_code=>'CX', :dialing_code => 618, :rworld_parature_id => 2493, :totale_parature_id => 4825),
      new(:iso_code => 170, :translation_key => 'Colombia615822742', :country_code=>'CO', :dialing_code => 57, :rworld_parature_id => 2693, :totale_parature_id => 4952),
      new(:iso_code => 174, :translation_key => 'Comoros83969020', :country_code=>'KM', :dialing_code => 269, :rworld_parature_id => 2694, :totale_parature_id => 4953),
      new(:iso_code => 184, :translation_key => 'Cook_Islands197277723', :country_code=>'CK', :dialing_code => 682, :rworld_parature_id => 2495, :totale_parature_id => 4826),
      new(:iso_code => 188, :translation_key => 'Costa_Rica1071083641', :country_code=>'CR', :dialing_code => 506, :rworld_parature_id => 2496, :totale_parature_id => 4827),
      new(:iso_code => 384, :translation_key => 'Cte_dIvoire6728198', :country_code=>'CI', :dialing_code => 225, :rworld_parature_id => 2695, :totale_parature_id => 4954),
      new(:iso_code => 191, :translation_key => 'Croatia1022555501', :country_code=>'HR', :dialing_code => 385, :rworld_parature_id => 2497, :totale_parature_id => 4828),
      new(:iso_code => 192, :translation_key => 'Cuba360575244', :country_code=>'CU', :dialing_code => 53, :rworld_parature_id => 2696, :totale_parature_id => 4955),
      new(:iso_code => 196, :translation_key => 'Cyprus3604273', :country_code=>'CY', :dialing_code => 357, :rworld_parature_id => 2498, :totale_parature_id => 4829),
      new(:iso_code => 203, :translation_key => 'Czech_Republic935810511', :country_code=>'CZ', :dialing_code => 420, :rworld_parature_id => 2499, :totale_parature_id => 4830),
      new(:iso_code => 208, :translation_key => 'Denmark794287237', :country_code=>'DK', :dialing_code => 45, :rworld_parature_id => 2500, :totale_parature_id => 4831),
      # FIXME
      #new(:iso_code => , :translation_key => 'Diego_Garcia982893545', :country_code=>'', :dialing_code => 246, :totale_parature_id => 4956),
      new(:iso_code => 262, :translation_key => 'Djibouti27094674', :country_code=>'DJ', :dialing_code => 253, :rworld_parature_id => 2698, :totale_parature_id => 4957),
      new(:iso_code => 212, :translation_key => 'Dominica697276373', :country_code=>'DM', :dialing_code => 1767, :rworld_parature_id => 2501, :totale_parature_id => 4832),
      new(:iso_code => 214, :translation_key => 'Dominican_Republic3222141', :country_code=>'DO', :valid_dialing_codes => [1809, 1829, 1849], :rworld_parature_id => 2699, :totale_parature_id => 4958),
      new(:iso_code => 180, :translation_key => 'DR_Congo659423631', :country_code=>'CD', :dialing_code => 243, :rworld_parature_id => 2700, :totale_parature_id => 4959),
      new(:iso_code => 218, :translation_key => 'Ecuador735690413', :country_code=>'EC', :dialing_code => 593, :rworld_parature_id => 2502, :totale_parature_id => 4833),
      new(:iso_code => 818, :translation_key => 'Egypt988753829', :country_code=>'EG', :dialing_code => 20, :rworld_parature_id => 2701, :totale_parature_id => 4960),
      new(:iso_code => 222, :translation_key => 'El_Salvador548097243', :country_code=>'SV', :dialing_code => 503, :rworld_parature_id => 2702, :totale_parature_id => 4961),
      new(:iso_code => 226, :translation_key => 'Equatorial_Guinea24142793', :country_code=>'GQ', :dialing_code => 240, :rworld_parature_id => 2703, :totale_parature_id => 4962),
      new(:iso_code => 232, :translation_key => 'Eritrea1057071455', :country_code=>'ER', :dialing_code => 291, :rworld_parature_id => 2704, :totale_parature_id => 4963),
      new(:iso_code => 233, :translation_key => 'Estonia663587500', :country_code=>'EE', :dialing_code => 372, :rworld_parature_id => 2503, :totale_parature_id => 4834),
      new(:iso_code => 231, :translation_key => 'Ethiopia1019111372', :country_code=>'ET', :dialing_code => 251, :rworld_parature_id => 2705, :totale_parature_id => 4964),
      new(:iso_code => 234, :translation_key => 'Faeroe_Islands1071674642', :country_code=>'FO', :dialing_code => 298, :rworld_parature_id => 2505, :totale_parature_id => 4836),
      new(:iso_code => 238, :translation_key => 'Falkland_Islands_Malvinas525078864', :country_code=>'FK', :dialing_code => 500, :rworld_parature_id => 2504, :totale_parature_id => 4835),
      new(:iso_code => 242, :translation_key => 'Fiji329029897', :country_code=>'FJ', :dialing_code => 679, :rworld_parature_id => 2506, :totale_parature_id => 4837),
      new(:iso_code => 246, :translation_key => 'Finland634951737', :country_code=>'FI', :dialing_code => 358, :rworld_parature_id => 2507, :totale_parature_id => 4838),
      new(:iso_code => 250, :translation_key => 'France675282492', :country_code=>'FR', :dialing_code => 33, :rworld_parature_id => 2508, :totale_parature_id => 4839),
      new(:iso_code => 254, :translation_key => 'French_Guiana199328382', :country_code=>'GF', :dialing_code => 594, :rworld_parature_id => 2509, :totale_parature_id => 4840),
      new(:iso_code => 258, :translation_key => 'French_Polynesia223052443', :country_code=>'PF', :dialing_code => 689, :rworld_parature_id => 2510, :totale_parature_id => 4841),
      new(:iso_code => 260, :translation_key => 'French_Southern_Territories47618723', :country_code=>'TF', :dialing_code => 33, :rworld_parature_id => 2511, :totale_parature_id => 4842),
      new(:iso_code => 266, :translation_key => 'Gabon630661293', :country_code=>'GA', :dialing_code => 241, :rworld_parature_id => 2706, :totale_parature_id => 4965),
      new(:iso_code => 270, :translation_key => 'Gambia502765091', :country_code=>'GM', :dialing_code => 220, :rworld_parature_id => 2707, :totale_parature_id => 4966),
      new(:iso_code => 268, :translation_key => 'Georgia3313991', :country_code=>'GE', :dialing_code => 995, :rworld_parature_id => 2708, :totale_parature_id => 4967),
      new(:iso_code => 276, :translation_key => 'Germany412623799', :country_code=>'DE', :dialing_code => 49, :rworld_parature_id => 2512, :totale_parature_id => 4843),
      new(:iso_code => 288, :translation_key => 'Ghana319730876', :country_code=>'GH', :dialing_code => 233, :rworld_parature_id => 2709, :totale_parature_id => 4968),
      new(:iso_code => 292, :translation_key => 'Gibraltar527128858', :country_code=>'GI', :dialing_code => 350, :rworld_parature_id => 2513, :totale_parature_id => 4844),
      new(:iso_code => 300, :translation_key => 'Greece227024972', :country_code=>'GR', :dialing_code => 30, :rworld_parature_id => 2514, :totale_parature_id => 4845),
      new(:iso_code => 304, :translation_key => 'Greenland329056287', :country_code=>'GL', :dialing_code => 299, :rworld_parature_id => 2515, :totale_parature_id => 4846),
      new(:iso_code => 308, :translation_key => 'Grenada1040011525', :country_code=>'GD', :dialing_code => 1473, :rworld_parature_id => 2516, :totale_parature_id => 4847),
      new(:iso_code => 312, :translation_key => 'Guadeloupe379999304', :country_code=>'GP', :dialing_code => 590, :rworld_parature_id => 2517, :totale_parature_id => 4848),
      new(:iso_code => 316, :translation_key => 'Guam577577939', :country_code=>'GU', :dialing_code => 1671, :rworld_parature_id => 2518, :totale_parature_id => 4849),
      new(:iso_code => 320, :translation_key => 'Guatemala301878073', :country_code=>'GT', :dialing_code => 502, :rworld_parature_id => 2710, :totale_parature_id => 4969),
      new(:iso_code => 831, :translation_key => 'Guernsey741754512', :country_code=>'GG', :dialing_code => 44, :rworld_parature_id => 2711, :totale_parature_id => 4970),
      new(:iso_code => 624, :translation_key => 'GuineaBissau301901698', :country_code=>'GW', :dialing_code => 245, :rworld_parature_id => 2713, :totale_parature_id => 4972),
      new(:iso_code => 324, :translation_key => 'Guinea18567958', :country_code=>'GN', :dialing_code => 224, :rworld_parature_id => 2712, :totale_parature_id => 4971),
      new(:iso_code => 328, :translation_key => 'Guyana499445291', :country_code=>'GY', :dialing_code => 592, :rworld_parature_id => 2519, :totale_parature_id => 4850),
      new(:iso_code => 332, :translation_key => 'Haiti281670703', :country_code=>'HT', :dialing_code => 509, :rworld_parature_id => 2520, :totale_parature_id => 4851),
      new(:iso_code => 334, :translation_key => 'Heard_Island_and_McDonald_Islands807996996', :country_code=>'HM', :dialing_code => 61, :rworld_parature_id => 2521, :totale_parature_id => 4852),
      new(:iso_code => 336, :translation_key => 'Holy_See712034836', :country_code=>'VA', :dialing_code => 39, :rworld_parature_id => 2522, :totale_parature_id => 4853),
      new(:iso_code => 340, :translation_key => 'Honduras951537203', :country_code=>'HN', :dialing_code => 504, :rworld_parature_id => 2714, :totale_parature_id => 4973),
      new(:iso_code => 344, :translation_key => 'Hong_Kong549731793', :country_code=>'HK', :dialing_code => 852, :rworld_parature_id => 2523, :totale_parature_id => 4854),
      new(:iso_code => 348, :translation_key => 'Hungary99396528', :country_code=>'HU', :dialing_code => 36, :rworld_parature_id => 2524, :totale_parature_id => 4855),
      new(:iso_code => 352, :translation_key => 'Iceland992936287', :country_code=>'IS', :dialing_code => 354, :rworld_parature_id => 2525, :totale_parature_id => 4856),
      new(:iso_code => 356, :translation_key => 'India174838150', :country_code=>'IN', :dialing_code => 91, :rworld_parature_id => 2715, :totale_parature_id => 4974),
      new(:iso_code => 360, :translation_key => 'Indonesia802282732', :country_code=>'ID', :dialing_code => 62, :rworld_parature_id => 2716, :totale_parature_id => 4975),
      new(:iso_code => 364, :translation_key => 'Iran14496359', :country_code=>'IR', :dialing_code => 98, :rworld_parature_id => 2717, :totale_parature_id => 4976),
      new(:iso_code => 368, :translation_key => 'Iraq14496362', :country_code=>'IQ', :dialing_code => 964, :rworld_parature_id => 2718, :totale_parature_id => 4977),
      new(:iso_code => 372, :translation_key => 'Ireland198147816', :country_code=>'IE', :dialing_code => 353, :rworld_parature_id => 2526, :totale_parature_id => 4857),
      new(:iso_code => 833, :translation_key => 'Isle_of_Man941976139', :country_code=>'IM', :dialing_code => 44, :rworld_parature_id => 2719, :totale_parature_id => 4978),
      new(:iso_code => 376, :translation_key => 'Israel1006147925', :country_code=>'IL', :dialing_code => 972, :rworld_parature_id => 2527, :totale_parature_id => 4858),
      new(:iso_code => 380, :translation_key => 'Italy550180361', :country_code=>'IT', :dialing_code => 39, :rworld_parature_id => 2528, :totale_parature_id => 4859),
      new(:iso_code => 388, :translation_key => 'Jamaica277553392', :country_code=>'JM', :dialing_code => 1876, :rworld_parature_id => 2529, :totale_parature_id => 4860),
      new(:iso_code => 392, :translation_key => 'Japan20450591', :country_code=>'JP', :dialing_code => 81, :rworld_parature_id => 2530, :totale_parature_id => 4861),
      new(:iso_code => 832, :translation_key => 'Jersey659931607', :country_code=>'JE', :dialing_code => 44, :rworld_parature_id => 2720, :totale_parature_id => 4979),
      new(:iso_code => 400, :translation_key => 'Jordan1003932497', :country_code=>'JO', :dialing_code => 962, :rworld_parature_id => 2721, :totale_parature_id => 4980),
      new(:iso_code => 398, :translation_key => 'Kazakhstan925487632', :country_code=>'KZ', :dialing_code => 7, :rworld_parature_id => 2722, :totale_parature_id => 4981),
      new(:iso_code => 166, :translation_key => 'Keeling_Islands855467776', :country_code=>'', :dialing_code => 61, :rworld_parature_id => 2723, :totale_parature_id => 4982),
      new(:iso_code => 404, :translation_key => 'Kenya69953539', :country_code=>'KE', :dialing_code => 254, :rworld_parature_id => 2724, :totale_parature_id => 4983),
      new(:iso_code => 296, :translation_key => 'Kiribati601900589', :country_code=>'KI', :dialing_code => 686, :rworld_parature_id => 2531, :totale_parature_id => 4862),
      new(:iso_code => 414, :translation_key => 'Kuwait575214787', :country_code=>'KW', :dialing_code => 965, :rworld_parature_id => 2725, :totale_parature_id => 4984),
      new(:iso_code => 417, :translation_key => 'Kyrgyzstan39802207', :country_code=>'KG', :dialing_code => 996, :rworld_parature_id => 2726, :totale_parature_id => 4985),
      new(:iso_code => 418, :translation_key => 'Laos3849211', :country_code=>'LA', :dialing_code => 856, :rworld_parature_id => 2791, :totale_parature_id => 5047),
      new(:iso_code => 428, :translation_key => 'Latvia509768177', :country_code=>'LV', :dialing_code => 371, :rworld_parature_id => 2533, :totale_parature_id => 4863),
      new(:iso_code => 422, :translation_key => 'Lebanon768592725', :country_code=>'LB', :dialing_code => 961, :rworld_parature_id => 2727, :totale_parature_id => 4986),
      new(:iso_code => 426, :translation_key => 'Lesotho1062656205', :country_code=>'LS', :dialing_code => 266, :rworld_parature_id => 2728, :totale_parature_id => 4987),
      new(:iso_code => 430, :translation_key => 'Liberia1019951122', :country_code=>'LR', :dialing_code => 231, :rworld_parature_id => 2729, :totale_parature_id => 4988),
      new(:iso_code => 434, :translation_key => 'Libya206276818', :country_code=>'LY', :dialing_code => 218, :rworld_parature_id => 2730, :totale_parature_id => 4989),
      new(:iso_code => 438, :translation_key => 'Liechtenstein459782328', :country_code=>'LI', :dialing_code => 423, :rworld_parature_id => 2534, :totale_parature_id => 4864),
      new(:iso_code => 440, :translation_key => 'Lithuania33733762', :country_code=>'LT', :dialing_code => 370, :rworld_parature_id => 2535, :totale_parature_id => 4865),
      new(:iso_code => 442, :translation_key => 'Luxembourg421291458', :country_code=>'LU', :dialing_code => 352, :rworld_parature_id => 2536, :totale_parature_id => 4866),
      new(:iso_code => 446, :translation_key => 'Macao1034864397', :country_code=>'MO', :dialing_code => 853, :rworld_parature_id => 2789, :totale_parature_id => 5045),
      new(:iso_code => 807, :translation_key => 'Macedonia1004806105', :country_code=>'MK', :dialing_code => 389, :rworld_parature_id => 2790, :totale_parature_id => 5046),
      new(:iso_code => 450, :translation_key => 'Madagascar326349000', :country_code=>'MG', :dialing_code => 261, :rworld_parature_id => 2731, :totale_parature_id => 4990),
      new(:iso_code => 454, :translation_key => 'Malawi986476518', :country_code=>'MW', :dialing_code => 265, :rworld_parature_id => 2732, :totale_parature_id => 4991),
      new(:iso_code => 458, :translation_key => 'Malaysia56120464', :country_code=>'MY', :dialing_code => 60, :rworld_parature_id => 2539, :totale_parature_id => 4867),
      new(:iso_code => 462, :translation_key => 'Maldives392405998', :country_code=>'MV', :dialing_code => 960, :rworld_parature_id => 2540, :totale_parature_id => 4868),
      new(:iso_code => 466, :translation_key => 'Mali808626803', :country_code=>'ML', :dialing_code => 223, :rworld_parature_id => 2733, :totale_parature_id => 4992),
      new(:iso_code => 470, :translation_key => 'Malta956901987', :country_code=>'MT', :dialing_code => 356, :rworld_parature_id => 2541, :totale_parature_id => 4869),
      new(:iso_code => 584, :translation_key => 'Marshall_Islands287863104', :country_code=>'MH', :dialing_code => 692, :rworld_parature_id => 2542, :totale_parature_id => 4870),
      new(:iso_code => 474, :translation_key => 'Martinique250328319', :country_code=>'MQ', :dialing_code => 596, :rworld_parature_id => 2543, :totale_parature_id => 4871),
      new(:iso_code => 478, :translation_key => 'Mauritania259140188', :country_code=>'MR', :dialing_code => 222, :rworld_parature_id => 2734, :totale_parature_id => 4993),
      new(:iso_code => 480, :translation_key => 'Mauritius813700217', :country_code=>'MU', :dialing_code => 230, :rworld_parature_id => 2735, :totale_parature_id => 4994),
      new(:iso_code => 175, :translation_key => 'Mayotte720438155', :country_code=>'YT', :dialing_code => 262, :rworld_parature_id => 2736, :totale_parature_id => 4995),
      new(:iso_code => 484, :translation_key => 'Mexico21288479', :country_code=>'MX', :dialing_code => 52, :rworld_parature_id => 2544, :totale_parature_id => 4872),
      new(:iso_code => 583, :translation_key => 'Micronesia982248615', :country_code=>'FM', :dialing_code => 691, :rworld_parature_id => 2788, :totale_parature_id => 5044),
      new(:iso_code => 498, :translation_key => 'Moldova340107108', :country_code=>'MD', :dialing_code => 373, :rworld_parature_id => 2737, :totale_parature_id => 4996),
      new(:iso_code => 492, :translation_key => 'Monaco816679678', :country_code=>'MC', :dialing_code => 377, :rworld_parature_id => 2546, :totale_parature_id => 4873),
      new(:iso_code => 496, :translation_key => 'Mongolia660163234', :country_code=>'MN', :dialing_code => 976, :rworld_parature_id => 2547, :totale_parature_id => 4874),
      new(:iso_code => 499, :translation_key => 'Montenegro41150425', :country_code=>'ME', :dialing_code => 382, :rworld_parature_id => 2738, :totale_parature_id => 4997),
      new(:iso_code => 500, :translation_key => 'Montserrat747033720', :country_code=>'MS', :dialing_code => 1664, :rworld_parature_id => 2548, :totale_parature_id => 4875),
      new(:iso_code => 504, :translation_key => 'Morocco573169296', :country_code=>'MA', :dialing_code => 212, :rworld_parature_id => 2739, :totale_parature_id => 4998),
      new(:iso_code => 508, :translation_key => 'Mozambique23978275', :country_code=>'MZ', :dialing_code => 258, :rworld_parature_id => 2740, :totale_parature_id => 4999),
      new(:iso_code => 104, :translation_key => 'Myanmar719155201', :country_code=>'MM', :dialing_code => 95, :rworld_parature_id => 2741, :totale_parature_id => 5000),
      new(:iso_code => 516, :translation_key => 'Namibia666065785', :country_code=>'NA', :dialing_code => 264, :rworld_parature_id => 2742, :totale_parature_id => 5001),
      new(:iso_code => 520, :translation_key => 'Nauru160597774', :country_code=>'NR', :dialing_code => 674, :rworld_parature_id => 2549, :totale_parature_id => 4876),
      new(:iso_code => 524, :translation_key => 'Nepal958195753', :country_code=>'NP', :dialing_code => 977, :rworld_parature_id => 2550, :totale_parature_id => 4877),
      new(:iso_code => 530, :translation_key => 'Netherlands_Antilles61758873', :country_code=>'AN', :dialing_code => 599, :rworld_parature_id => 2552, :totale_parature_id => 4879),
      new(:iso_code => 528, :translation_key => 'Netherlands22512749', :country_code=>'NL', :dialing_code => 31, :rworld_parature_id => 2551, :totale_parature_id => 4878),
      new(:iso_code => 540, :translation_key => 'New_Caledonia354142930', :country_code=>'NC', :dialing_code => 687, :rworld_parature_id => 2553, :totale_parature_id => 4880),
      new(:iso_code => 554, :translation_key => 'New_Zealand673405591', :country_code=>'NZ', :dialing_code => 64, :rworld_parature_id => 2554, :totale_parature_id => 4881),
      new(:iso_code => 558, :translation_key => 'Nicaragua49156523', :country_code=>'NI', :dialing_code => 505, :rworld_parature_id => 2743, :totale_parature_id => 5002),
      new(:iso_code => 562, :translation_key => 'Niger96381425', :country_code=>'NE', :dialing_code => 227, :rworld_parature_id => 2744, :totale_parature_id => 5003),
      new(:iso_code => 566, :translation_key => 'Nigeria1020781131', :country_code=>'NG', :dialing_code => 234, :rworld_parature_id => 2745, :totale_parature_id => 5004),
      new(:iso_code => 570, :translation_key => 'Niue465110043', :country_code=>'NU', :dialing_code => 683, :rworld_parature_id => 2555, :totale_parature_id => 4882),
      new(:iso_code => 574, :translation_key => 'Norfolk_Island806785028', :country_code=>'NF', :dialing_code => 672, :rworld_parature_id => 2556, :totale_parature_id => 4883),
      new(:iso_code => 580, :translation_key => 'Northern_Mariana_Islands41665137', :country_code=>'MP', :dialing_code => 1670, :rworld_parature_id => 2558, :totale_parature_id => 4884),
      new(:iso_code => 578, :translation_key => 'Norway692471205', :country_code=>'NO', :dialing_code => 47, :rworld_parature_id => 2559, :totale_parature_id => 4885),
      new(:iso_code => 512, :translation_key => 'Oman238378516', :country_code=>'OM', :dialing_code => 968, :rworld_parature_id => 2746, :totale_parature_id => 5005),
      new(:iso_code => 586, :translation_key => 'Pakistan549566661', :country_code=>'PK', :dialing_code => 92, :rworld_parature_id => 2747, :totale_parature_id => 5006),
      new(:iso_code => 585, :translation_key => 'Palau285638346', :country_code=>'PW', :dialing_code => 680, :rworld_parature_id => 2560, :totale_parature_id => 4886),
      new(:iso_code => 275, :translation_key => 'Palestine621061343', :country_code=>'PS', :dialing_code => 970, :rworld_parature_id => 2787, :totale_parature_id => 5043),
      new(:iso_code => 591, :translation_key => 'Panama682526535', :country_code=>'PA', :dialing_code => 507, :rworld_parature_id => 2562, :totale_parature_id => 4887),
      new(:iso_code => 598, :translation_key => 'Papua_New_Guinea438815064', :country_code=>'PG', :dialing_code => 675, :rworld_parature_id => 2563, :totale_parature_id => 4888),
      new(:iso_code => 600, :translation_key => 'Paraguay665730623', :country_code=>'PY', :dialing_code => 595, :rworld_parature_id => 2748, :totale_parature_id => 5007),
      new(:iso_code => 604, :translation_key => 'Peru976351688', :country_code=>'PE', :dialing_code => 51, :rworld_parature_id => 2564, :totale_parature_id => 4889),
      new(:iso_code => 608, :translation_key => 'Philippines178446280', :country_code=>'PH', :dialing_code => 63, :rworld_parature_id => 2749, :totale_parature_id => 5008),
      new(:iso_code => 612, :translation_key => 'Pitcairn226829514', :country_code=>'PN', :dialing_code => 64, :rworld_parature_id => 2565, :totale_parature_id => 4890),
      new(:iso_code => 616, :translation_key => 'Poland872484370', :country_code=>'PL', :dialing_code => 48, :rworld_parature_id => 2566, :totale_parature_id => 4891),
      new(:iso_code => 620, :translation_key => 'Portugal281551614', :country_code=>'PT', :dialing_code => 351, :rworld_parature_id => 2567, :totale_parature_id => 4892),
      new(:iso_code => 630, :translation_key => 'Puerto_Rico954454096', :country_code=>'PR', :dialing_code => 1787, :rworld_parature_id => 2568, :totale_parature_id => 4893),
      new(:iso_code => 634, :translation_key => 'Qatar618512216', :country_code=>'QA', :dialing_code => 974, :rworld_parature_id => 2750, :totale_parature_id => 5009),
      new(:iso_code => 178, :translation_key => 'Republic_of_Congo986758438', :country_code=>'CG', :dialing_code => 242, :rworld_parature_id => 2751, :totale_parature_id => 5010),
      new(:iso_code => 638, :translation_key => 'Runion424722352', :country_code=>'RE', :dialing_code => 262, :rworld_parature_id => 2786, :totale_parature_id => 5042),
      new(:iso_code => 642, :translation_key => 'Romania98681331', :country_code=>'RO', :dialing_code => 40, :rworld_parature_id => 2752, :totale_parature_id => 5011),
      new(:iso_code => 643, :translation_key => 'Russia956355617', :country_code=>'RU', :dialing_code => 7, :rworld_parature_id => 2753, :totale_parature_id => 5012),
      new(:iso_code => 646, :translation_key => 'Rwanda14746562', :country_code=>'RW', :dialing_code => 250, :rworld_parature_id => 2754, :totale_parature_id => 5013),
      new(:iso_code => 652, :translation_key => 'SaintBarthlemy695938427', :country_code=>'BL', :dialing_code => 590, :rworld_parature_id => 2755, :totale_parature_id => 5014),
      new(:iso_code => 654, :translation_key => 'Saint_Helena391800230', :country_code=>'SH', :dialing_code => 290, :rworld_parature_id => 2570, :totale_parature_id => 4894),
      new(:iso_code => 659, :translation_key => 'Saint_Kitts_and_Nevis921826334', :country_code=>'KN', :dialing_code => 1869, :rworld_parature_id => 2571, :totale_parature_id => 4895),
      new(:iso_code => 662, :translation_key => 'Saint_Lucia149597172', :country_code=>'LC', :dialing_code => 1758, :rworld_parature_id => 2572, :totale_parature_id => 4896),
      new(:iso_code => 663, :translation_key => 'SaintMartin_French_part497303862', :country_code=>'MF', :dialing_code => 590, :rworld_parature_id => 2756, :totale_parature_id => 5015),
      new(:iso_code => 666, :translation_key => 'Saint_Pierre_and_Miquelon854330676', :country_code=>'PM', :dialing_code => 508, :rworld_parature_id => 2573, :totale_parature_id => 4897),
      new(:iso_code => 670, :translation_key => 'Saint_Vincent_and_the_Grenadines38825029', :country_code=>'VC', :dialing_code => 1784, :rworld_parature_id => 2574, :totale_parature_id => 4898),
      new(:iso_code => 882, :translation_key => 'Samoa608552917', :country_code=>'WS', :dialing_code => 685, :rworld_parature_id => 2575, :totale_parature_id => 4899),
      new(:iso_code => 674, :translation_key => 'San_Marino606489458', :country_code=>'SM', :dialing_code => 378, :rworld_parature_id => 2576, :totale_parature_id => 4900),
      new(:iso_code => 678, :translation_key => 'Sao_Tome_and_Principe780785750', :country_code=>'ST', :dialing_code => 239, :rworld_parature_id => 2757, :totale_parature_id => 5016),
      new(:iso_code => 682, :translation_key => 'Saudi_Arabia61481940', :country_code=>'SA', :dialing_code => 966, :rworld_parature_id => 2758, :totale_parature_id => 5017),
      new(:iso_code => 686, :translation_key => 'Senegal323848626', :country_code=>'SN', :dialing_code => 221, :rworld_parature_id => 2759, :totale_parature_id => 5018),
      new(:iso_code => 688, :translation_key => 'Serbia461125243', :country_code=>'RS', :dialing_code => 381, :rworld_parature_id => 2785, :totale_parature_id => 5041),
      new(:iso_code => 690, :translation_key => 'Seychelles711669679', :country_code=>'SC', :dialing_code => 248, :rworld_parature_id => 2760, :totale_parature_id => 5019),
      new(:iso_code => 694, :translation_key => 'Sierra_Leone269404278', :country_code=>'SL', :dialing_code => 232, :rworld_parature_id => 2761, :totale_parature_id => 5020),
      new(:iso_code => 702, :translation_key => 'Singapore288536562', :country_code=>'SG', :dialing_code => 65, :rworld_parature_id => 2578, :totale_parature_id => 4901),
      new(:iso_code => 703, :translation_key => 'Slovakia82595665', :country_code=>'SK', :dialing_code => 421, :rworld_parature_id => 2579, :totale_parature_id => 4902),
      new(:iso_code => 705, :translation_key => 'Slovenia881184186', :country_code=>'SI', :dialing_code => 386, :rworld_parature_id => 2580, :totale_parature_id => 4903),
      new(:iso_code => 90, :translation_key => 'Solomon_Islands20159645', :country_code=>'SB', :dialing_code => 677, :rworld_parature_id => 2581, :totale_parature_id => 4904),
      new(:iso_code => 706, :translation_key => 'Somalia839482360', :country_code=>'SO', :dialing_code => 252, :rworld_parature_id => 2762, :totale_parature_id => 5021),
      new(:iso_code => 710, :translation_key => 'South_Africa322479412', :country_code=>'ZA', :dialing_code => 27, :rworld_parature_id => 2582, :totale_parature_id => 4905),
      new(:iso_code => 239, :translation_key => 'South_Georgia_and_the_South_Sandwich_Islands266443248', :country_code=>'GS', :dialing_code => 500, :rworld_parature_id => 2583, :totale_parature_id => 4906),
      new(:iso_code => 410, :translation_key => 'South_Korea368309560', :country_code=>'KR', :dialing_code => 82, :rworld_parature_id => 2584, :totale_parature_id => 4907),
      new(:iso_code => 724, :translation_key => 'Spain223441889', :country_code=>'ES', :dialing_code => 34, :rworld_parature_id => 2585, :totale_parature_id => 4908),
      new(:iso_code => 144, :translation_key => 'Sri_Lanka732599136', :country_code=>'LK', :dialing_code => 94, :rworld_parature_id => 2586, :totale_parature_id => 4909),
      new(:iso_code => 736, :translation_key => 'Sudan21604823', :country_code=>'SD', :dialing_code => 249, :rworld_parature_id => 2763, :totale_parature_id => 5022),
      new(:iso_code => 740, :translation_key => 'Suriname662837544', :country_code=>'SR', :dialing_code => 597, :rworld_parature_id => 2587, :totale_parature_id => 4910),
      new(:iso_code => 744, :translation_key => 'Svalbard_and_Jan_Mayen_Islands50598595', :country_code=>'SJ', :dialing_code => 47, :rworld_parature_id => 2588, :totale_parature_id => 4911),
      new(:iso_code => 748, :translation_key => 'Swaziland538575865', :country_code=>'SZ', :dialing_code => 268, :rworld_parature_id => 2764, :totale_parature_id => 5023),
      new(:iso_code => 752, :translation_key => 'Sweden761795189', :country_code=>'SE', :dialing_code => 46, :rworld_parature_id => 2589, :totale_parature_id => 4912),
      new(:iso_code => 756, :translation_key => 'Switzerland220511481', :country_code=>'CH', :dialing_code => 41, :rworld_parature_id => 2590, :totale_parature_id => 4913),
      new(:iso_code => 158, :translation_key => 'Taiwan704576955', :country_code=>'TW', :dialing_code => 886, :rworld_parature_id => 2591, :totale_parature_id => 4914),
      new(:iso_code => 762, :translation_key => 'Tajikistan921868902', :country_code=>'TJ', :dialing_code => 992, :rworld_parature_id => 2765, :totale_parature_id => 5024),
      new(:iso_code => 834, :translation_key => 'Tanzania392285690', :country_code=>'TZ', :dialing_code => 255, :rworld_parature_id => 2766, :totale_parature_id => 5025),
      new(:iso_code => 764, :translation_key => 'Thailand332250081', :country_code=>'TH', :dialing_code => 66, :rworld_parature_id => 2767, :totale_parature_id => 5026),
      new(:iso_code => 626, :translation_key => 'TimorLeste12436372', :country_code=>'TL', :dialing_code => 670, :rworld_parature_id => 2768, :totale_parature_id => 5027),
      new(:iso_code => 768, :translation_key => 'Togo14240786', :country_code=>'TG', :dialing_code => 228, :rworld_parature_id => 2592, :totale_parature_id => 4915),
      new(:iso_code => 772, :translation_key => 'Tokelau694214356', :country_code=>'TK', :dialing_code => 690, :rworld_parature_id => 2593, :totale_parature_id => 4916),
      new(:iso_code => 776, :translation_key => 'Tonga704257503', :country_code=>'TO', :dialing_code => 676, :rworld_parature_id => 2594, :totale_parature_id => 4917),
      new(:iso_code => 780, :translation_key => 'Trinidad_and_Tobago622771075', :country_code=>'TT', :dialing_code => 1868, :rworld_parature_id => 2595, :totale_parature_id => 4918),
      new(:iso_code => 788, :translation_key => 'Tunisia445161537', :country_code=>'TN', :dialing_code => 216, :rworld_parature_id => 2769, :totale_parature_id => 5028),
      new(:iso_code => 792, :translation_key => 'Turkey1062499239', :country_code=>'TR', :dialing_code => 90, :rworld_parature_id => 2770, :totale_parature_id => 5029),
      new(:iso_code => 795, :translation_key => 'Turkmenistan729609051', :country_code=>'TM', :dialing_code => 993, :rworld_parature_id => 2771, :totale_parature_id => 5030),
      new(:iso_code => 796, :translation_key => 'Turks_and_Caicos_Islands113276813', :country_code=>'TC', :dialing_code => 1649, :rworld_parature_id => 2596, :totale_parature_id => 4919),
      new(:iso_code => 798, :translation_key => 'Tuvalu209001651', :country_code=>'TV', :dialing_code => 688, :rworld_parature_id => 2597, :totale_parature_id => 4920),
      new(:iso_code => 800, :translation_key => 'Uganda79573260', :country_code=>'UG', :dialing_code => 256, :rworld_parature_id => 2772, :totale_parature_id => 5031),
      new(:iso_code => 804, :translation_key => 'Ukraine118361603', :country_code=>'UA', :dialing_code => 380, :rworld_parature_id => 2773, :totale_parature_id => 5032),
      new(:iso_code => 784, :translation_key => 'United_Arab_Emirates285780795', :country_code=>'AE', :dialing_code => 971, :rworld_parature_id => 2774, :totale_parature_id => 5033),
      new(:iso_code => 826, :translation_key => 'United_Kingdom7996048', :country_code=>'GB', :dialing_code => 44, :rworld_parature_id => 2598, :totale_parature_id => 4921),
      new(:iso_code => 840, :translation_key => 'United_States184708854', :country_code=>'US', :dialing_code => 1, :rworld_parature_id => 2599, :totale_parature_id => 4922),
      new(:iso_code => 858, :translation_key => 'Uruguay116238807', :country_code=>'UY', :dialing_code => 598, :rworld_parature_id => 2601, :totale_parature_id => 4923),
      new(:iso_code => 860, :translation_key => 'Uzbekistan630945337', :country_code=>'UZ', :dialing_code => 998, :rworld_parature_id => 2775, :totale_parature_id => 5034),
      new(:iso_code => 548, :translation_key => 'Vanuatu58177466', :country_code=>'VU', :dialing_code => 678, :rworld_parature_id => 2602, :totale_parature_id => 4924),
      new(:iso_code => 862, :translation_key => 'Venezuela640107971', :country_code=>'VE', :dialing_code => 58, :rworld_parature_id => 2776, :totale_parature_id => 5035),
      new(:iso_code => 704, :translation_key => 'Viet_Nam515724226', :country_code=>'VN', :dialing_code => 84, :rworld_parature_id => 2777, :totale_parature_id => 5036),
      new(:iso_code => 850, :translation_key => 'Virgin_Islands_US494923456', :country_code=>'VI', :dialing_code => 1340, :rworld_parature_id => 2604, :totale_parature_id => 4926),
      new(:iso_code => 876, :translation_key => 'Wallis_and_Futuna_Islands647714221', :country_code=>'WF', :dialing_code => 681, :rworld_parature_id => 2605, :totale_parature_id => 4927),
      new(:iso_code => 732, :translation_key => 'Western_Sahara839716874', :country_code=>'EH', :dialing_code => 212, :rworld_parature_id => 2778, :totale_parature_id => 5037),
      new(:iso_code => 887, :translation_key => 'Yemen803376793', :country_code=>'YE', :dialing_code => 967, :rworld_parature_id => 2779, :totale_parature_id => 5038),
      new(:iso_code => 894, :translation_key => 'Zambia75365191', :country_code=>'ZM', :dialing_code => 260, :rworld_parature_id => 2780, :totale_parature_id => 5039),
      new(:iso_code => 716, :translation_key => 'Zimbabwe226730608', :country_code=>'ZW', :dialing_code => 263, :rworld_parature_id => 2781, :totale_parature_id => 5040),
    ]

    COUNTRIES_WITH_COUNTRY_CODES = COUNTRIES.map{|country| country.country_code == '' ? nil : country}.delete_if{|hash| hash.nil?}

    COUNTRIES_HASH = COUNTRIES.map_to_hash {|country| {country.iso_code => country}}
    COUNTRY_CODE_HASH = COUNTRIES_WITH_COUNTRY_CODES.map_to_hash {|country| {country.country_code => country}}

    class << self

      def options_for_select(options = {})
        iso_mapped_country_array = Country.all_sorted.map {|c| [c.name, c.iso_code] }
        unless options.has_key?(:include_instructions) && !options[:include_instructions]
          iso_mapped_country_array.unshift([no_screenshot_translate("Please_select_one680788636"), nil])
        end
        iso_mapped_country_array
      end

      def options_for_select_country_code
        Country.all_with_country_codes_sorted.map {|c| [c.name, c.country_code] }
      end

      # NOT sorted
      def all_with_country_codes
        COUNTRIES_WITH_COUNTRY_CODES
      end

      def all_with_country_codes_sorted
        all_with_country_codes.sort_by{|country| Lion::Utilities.substitute_diacritics_for_ruby_sorting(country.name)}
      end

      # NOT sorted
      def all
        COUNTRIES
      end

      def all_sorted
        all.sort_by{|country| Lion::Utilities.substitute_diacritics_for_ruby_sorting(country.name)}
      end

      def find_by_iso_code(iso_code)
        COUNTRIES_HASH[iso_code]
      end

      def find_by_country_code(country_code)
        COUNTRY_CODE_HASH[country_code]
      end

      def valid_iso_codes
        COUNTRIES_HASH.keys
      end

      def valid_country_codes
        COUNTRY_CODE_HASH.keys
      end

      def iso_code_to_dialing_code_mappings
        all.map_to_hash {|c| {c.iso_code => c.dialing_code} }
      end

    end # class << self

    def to_s
      name
    end

    def name
      # same as using _ but doesn't make the harvester complain that we don't have a translation for the string "untranslated_name"
      unharvested_translate(translation_key, {}, false)
    end

    def default_locale_name
      Lion::Translate.translate_into(Lion.default_locale, translation_key, {}, false)
    end
  end
end