INSERT INTO lawbook (code, name, sentence, type)
VALUES 
    ('1.01', 'Failure to Stop at traffic signal (1pt)', 70, 'fine'),
    ('1.02', 'Illegal Parking', 35, 'fine'),
    ('1.03', 'Illegal U-Turn (1pt)', 45, 'fine'),
    ('1.04', 'Driving Unroadworthy Vehicle', 100, 'fine'),
    ('1.05', 'Obstruction of Traffic', 100, 'fine'),
    ('1.06', 'Failure to Yield to Emergency Lights (2pts)', 350, 'fine'),
    ('1.07', 'Driving with suspended license (6pts)', 500, 'fine'),
    ('1.08', 'Driving without license', 3, 'jail'),
    ('1.09a', 'Speeding (5-10+) (1pt)', 100, 'fine'),
    ('1.09b', 'Speeding (10-15) (1pt)', 175, 'fine'),
    ('1.09c', 'Speeding (15-25) (2pts)', 250, 'fine'),
    ('1.10', 'Reckless Driving (25+) (6pts)', 750, 'fine'),
    ('1.11', 'Illegal Passing (1pt)', 300, 'fine'),
    ('1.12', 'Unsafe Vehicle Equipment', 150, 'fine'),
    ('1.13', 'Driving without seatbelt', 100, 'fine'),
    ('1.14', 'Driving without headlights', 120, 'fine'),
    ('1.15', 'Motor Vehicle Contest (6pts)', 500, 'fine'),
    ('1.16', 'Failure to Maintain Lane (1pt)', 135, 'fine'),
    ('1.17', 'Riding in/on Back of a truck', 65, 'fine'),
    ('1.18', 'Operation of a Handheld Device while Driving (1pt)', 200, 'fine'),
    ('2.01', 'Misuse of Emergency Services Resources', 5, 'jail'),
    ('2.02', 'Public Indeceny', 5, 'jail'),
    ('2.03', 'Public Intoxication', 100, 'fine'),
    ('2.04', 'Disorderly Conduct', 150, 'fine'),
    ('2.05', 'Petty Theft', 500, 'fine'),
    ('2.06', 'Littering', 5, 'service'),
    ('2.07', 'Jaywalking', 50, 'fine'),
    ('2.08', 'Loitering', 200, 'fine'),
    ('2.09', 'Failure to Identify', 500, 'fine'),
    ('3.01a', 'Driving Under the influence 1st (12pts)', 5, 'jail'),
    ('3.01b', 'Driving Under the influence 2nd (12pts)', 10, 'jail'),
    ('3.01c', 'Driving Under the influence 3rd (20pts)', 20, 'jail'),
    ('3.02', 'Domestic Violnce', 10, 'jail'),
    ('3.03', 'Shoplifting', 10, 'jail'),
    ('3.04', 'Recieving Stolen Property', 10, 'jail'),
    ('3.05', 'Brandishing a Weapon', 5, 'jail'),
    ('3.06', 'Possession of a Firearm without a license', 10, 'jail'),
    ('3.07', 'Prostitution', 5, 'jail'),
    ('3.08', 'Solicitation of Prostitution', 10, 'jail'),
    ('3.09', 'Resisting Arrest', 10, 'jail'),
    ('3.10', 'Assault and Battery', 15, 'jail'),
    ('3.11', 'Arson', 15, 'jail'),
    ('3.12', "Tresspassing", 500, 'fine'),
    ('3.13', 'Disturbing the Peace', 500, 'fine'),
    ('3.14', 'Failure to Remain at Accident', 10, 'jail'),
    ('3.15a', 'Harrasment', 5, 'jail'),
    ('3.15b', 'Sexual Harrasment', 10, 'jail'),
    ('3.16', 'Vandalism', 10, 'jail'),
    ('3.17', 'Aiding and Abetting', 10, 'jail'),
    ('3.18', 'Eluding', 10, 'jail'),
    ('3.19', 'Contempt of Court', 5, 'jail'),
    ('3.20', 'Public Urination', 500, 'fine'),
    ('3.21', 'Indecent Exposure', 1000, 'fine'),
    ('3.22', 'Tampering', 15, 'jail'),
    ('3.23', 'Defamation', 1000, 'fine'),
    ('3.24', 'Violation of Probation (+ original sentence)', 10, 'jail'),
    ('4.01', '1st Degree Murder', 0, 'death'),
    ('4.02', '2nd Degree Murder', 60, 'jail'),
    ('4.03', 'Manslaughter', 25, 'jail'),
    ('4.04', 'Vehicular Manslaughter', 20, 'jail'),
    ('4.05', 'Attempted 1st Degree Murder', 60, 'jail'),
    ('4.06', 'Attempted 2nd Degree Murder', 25, 'jail'),
    ('4.07', 'Possession of an Illegal Weapon', 5, 'jail'),
    ('4.08', 'Aggrivated Battery', 15, 'jail'),
    ('4.09', 'Kidnapping', 10, 'jail'),
    ('4.10', 'False Imprisonment', 10, 'jail'),
    ('4.11', 'Torture', 20, 'jail'),
    ('4.12a', 'Monetary Fraud', 7500, 'fine'),
    ('4.12b', 'Basic Fraud', 10, 'jail'),
    ('4.13', 'Drug Distribution', 15, 'jail'),
    ('4.14', 'Drug Possesion', 5, 'jail'),
    ('4.15', 'Possesion of a Controlled Substance w/ Intent', 10, 'jail'),
    ('4.16', 'Buglary', 15, 'jail'),
    ('4.17a', 'Robbery', 10, 'jail'),
    ('4.17b', 'Armed Robbery', 15, 'jail'),
    ('4.18', 'Grand Theft', 10, 'jail'),
    ('4.19', 'Grand Theft Auto', 15, 'jail'),
    ('4.20', 'Obstruction of Justice', 15, 'jail'),
    ('4.21', 'Impersonation of a Government Offical', 10, 'jail'),
    ('4.22', 'Perjury', 5, 'jail'),
    ('4.23', 'Bribery', 5, 'jail'),
    ('4.24a', 'Evasion', 10, 'jail'),
    ('4.24b', 'Evasion w/ Bodily Harm', 20, 'jail'),
    ('4.25', 'Aggravated Assault', 15, 'jail'),
    ('4.26', 'Forgery', 10, 'jail'),
    ('4.27', 'Intent to Manufacture', 20, 'jail'),
    ('4.28', 'Conspiracy to Commit {X}', 0, 'jail'),
    ('4.29', 'Blackmailing', 10, 'jail'),
    ('5.01', 'Terrorism', 0, 'death'),
    ('5.02', 'Cyber Terrorism', 120, 'jail'),
    ('5.03', 'Corruption', 60, 'jail'),
    ('5.04', 'Entrapment', 60, 'jail'),
    ('5.05', 'Racketeering', 240, 'jail'),
    ('5.06', 'Laundering of Money', 120, 'jail'),
    ('5.07', 'Election Fraud', 240, 'jail'),
    ('5.08', 'Treason', 120, 'jail'),
    ('5.09', 'Extortion', 120, 'jail'),
    ('5.10', 'Embezzelment', 60, 'jail');