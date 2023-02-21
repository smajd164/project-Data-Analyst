-- PENYESUAIAN TIMESTAMP_OF_CRASH DENGAN ZONA WAKTU PADA TIAP NEGARA BAGIAN
create table crash_1 as
select x.* from
(select  *,
	case 
	 when state_name in ('Oklahoma','Mississippi','Louisiana',
							   'Arkansas','Missouri','South Dakota','Iowa',
							 'Minnesota','Wisconsin','Illinois','North Dakota',
							 'Nebraska','Kansas','Texas','Alabama') then 
	 						timestamp_of_crash at time zone 'US/Central'
	 when state_name in ('North Carolina','Florida','Vermont','Delaware',
						'New York','West Virginia','South Carolina',
						'New Jersey','Connecticut','District of Columbia',
						'Indiana','Massachusetts','Rhode Island','Ohio',
						'Pennsylvania','Kentucky','Virginia','Maryland',
						'Georgia','New Hampshire','Maine','Tennessee','Michigan') THEN
						    timestamp_of_crash at time zone 'US/Eastern'
	 when state_name in ('Colorado','New Mexico','Montana','Arizona','Utah',
						'Wyoming','Idaho') then timestamp_of_crash at time zone 'US/Mountain'
	 when state_name in ('Nevada','Washington','California','Oregon') then timestamp_of_crash at time zone 'US/Pacific'
	when state_name in ('Hawaii') then timestamp_of_crash at time zone 'US/Hawaii'
	when state_name in ('Alaska')then timestamp_of_crash at time zone 'US/Alaska'
	
	end timestamp_based_localtime
from crash) x

-- PENYESUAIAN KONDISI CAHAYA DENGAN WAKTU (JAM) Dan Desa/Kota
create table crash as
select x.* from
(select *,case when EXTRACT(hour from timestamp_based_localtime) in (20,21,22,23,00,01,02,03,04) and light_condition_name in ('Daylight','Dark - Not Lighted','Dusk','Dawn')
 and land_use_name in ('Urban') then 'Dark - Lighted'
 when EXTRACT(hour from timestamp_based_localtime) in (09,10,11,12,13,14,15,16) and light_condition_name in ('Dusk','Dark - Not Lighted','Dawn','Dark - Lighted','Dark - Unknown Lighting') 
 then 'Daylight' 
 when EXTRACT(hour from timestamp_based_localtime) in (20,21,22,23,00,01,02,03,04) and light_condition_name in ('Daylight','Dusk','Dawn','Dark - Lighted')
 and land_use_name in ('Rural','Trafficway Not in State Inventory') then 'Dark - Not Lighted'
 when EXTRACT(hour from timestamp_based_localtime) in (17,18,19) and light_condition_name in ('Daylight','Dark - Not Lighted','Dawn')
 then 'Dusk'
 when EXTRACT(hour from timestamp_based_localtime) in (05,06,07,08) and light_condition_name in ('Daylight','Dark - Not Lighted','Dark - Lighted','Dusk','Dark - Unknown Lighting')
 then 'Dawn'
 
 else light_condition_name end penyesuaian_kondisi_cahaya
from crash_1)x


-- Penyatuan tiap kolom yang sudah bersih
create table crash_2 as
select x.* from
(select (consecutive_number) as jumlah_laporan
, state_name,
(land_use_name) as desa_kota,
(functional_system_name) as tipe_jalan,
(manner_of_collision_name) as tipe_kecelakaan, 
(type_of_intersection_name) as tipe_persimpangan,
(atmospheric_conditions_1_name) as cuaca,
(number_of_fatalities) as kecelakaan_fatal,
(number_of_drunk_drivers) as pengemudi_mabuk,
(case when number_of_drunk_drivers > 0 
then 'Mabuk' ELSE 'Tidak Mabuk' END) as drunk_or_no,
to_char(timestamp_of_crash,'day') as hari,
    case 
     when state_name in ('Oklahoma','Mississippi','Louisiana',
                               'Arkansas','Missouri','South Dakota','Iowa',
                             'Minnesota','Wisconsin','Illinois','North Dakota',
                             'Nebraska','Kansas','Texas','Alabama') then 
                             timestamp_of_crash at time zone 'US/Central'
     when state_name in ('North Carolina','Florida','Vermont','Delaware',
                        'New York','West Virginia','South Carolina',
                        'New Jersey','Connecticut','District of Columbia',
                        'Indiana','Massachusetts','Rhode Island','Ohio',
                        'Pennsylvania','Kentucky','Virginia','Maryland',
                        'Georgia','New Hampshire','Maine','Tennessee','Michigan') THEN
                            timestamp_of_crash at time zone 'US/Eastern'
     when state_name in ('Colorado','New Mexico','Montana','Arizona','Utah',
                        'Wyoming','Idaho') then timestamp_of_crash at time zone 'US/Mountain'
     when state_name in ('Nevada','Washington','California','Oregon') then timestamp_of_crash at time zone 'US/Pacific'
    when state_name in ('Hawaii') then timestamp_of_crash at time zone 'US/Hawaii'
    when state_name in ('Alaska')then timestamp_of_crash at time zone 'US/Alaska'
end timestamp_based_localtime,
 EXTRACT(hour from timestamp_based_localtime) as jam,
case when EXTRACT(hour from timestamp_based_localtime) in (20,21,22,23,00,01,02,03,04) and light_condition_name in ('Daylight','Dark - Not Lighted','Dusk','Dawn')
 and land_use_name in ('Urban') then 'Dark - Lighted'
 when EXTRACT(hour from timestamp_based_localtime) in (09,10,11,12,13,14,15,16) and light_condition_name in ('Dusk','Dark - Not Lighted','Dawn','Dark - Lighted','Dark - Unknown Lighting') 
 then 'Daylight' 
 when EXTRACT(hour from timestamp_based_localtime) in (20,21,22,23,00,01,02,03,04) and light_condition_name in ('Daylight','Dusk','Dawn','Dark - Lighted')
 and land_use_name in ('Rural','Trafficway Not in State Inventory') then 'Dark - Not Lighted'
 when EXTRACT(hour from timestamp_based_localtime) in (17,18,19) and light_condition_name in ('Daylight','Dark - Not Lighted','Dawn')
 then 'Dusk'
 when EXTRACT(hour from timestamp_based_localtime) in (05,06,07,08) and light_condition_name in ('Daylight','Dark - Not Lighted','Dark - Lighted','Dusk','Dark - Unknown Lighting')
 then 'Dawn'
 
 else light_condition_name end penyesuaian_kondisi_cahaya
 
from crash
group by consecutive_number,state_name,desa_kota,
tipe_kecelakaan,tipe_persimpangan,
light_condition_name,cuaca,kecelakaan_fatal,
pengemudi_mabuk,hari,tipe_jalan,
timestamp_based_localtime,timestamp_of_crash
order by state_name) x

-- Pengembalian nama table
alter table crash_2
rename to crash

-- Tabel bersih
select * from crash