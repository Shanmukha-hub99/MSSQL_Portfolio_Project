select * from Events;     ---- Need to Clean Data Here

select * from EventSessions;  ---- Need to Clean Data Here

select * from EventSpeakers;  ---- Need to clean Data Here

select * from EventSponsors;  ---- Need to Clean Data Here

select * from Languages;

select * from SessionsDownloads;   --- Need to clean Data Here

select * from SessionsSpeakers;   


---- Removing Duplicates and Nulls from Events table

delete from events where  EventID is  null and EventName is  null;  --- Removing Null Data from Table 

select * from Events  order by eventid desc;

with cte as(
select *, ROW_NUMBER() over (partition by eventid,eventname,Attendeeestimate,EventDescription
							order by eventid) row_num from events)
							delete from cte where row_num>1;     ----- Deleting duplicates from Events table


--- Removing Unwanted Columns(Wrong Columns) in Events Table---------------

alter table events Drop column F13,F14 



------------- Cleaning EventSessions Table ------

Select * from EventSessions  where Eventid is null and sessionid is null and Title is null;  ---- No Null Data 

----- Deleting duplicates from EventSessions table 

with cte as(select *, ROW_NUMBER() over (partition by eventid,sessionid,track,title,speakerrole
							order by eventid) row_num from EventSessions)
							delete from cte where row_num>1;

select * from eventsessions;

--- Removing Unwanted Columns(Wrong Columns) in EventSessions Table---------------

alter table EventSessions Drop column F18,F19,F20,Track#1,DownloadLinks,Speakers,LanguageDesc,[check]

----------- Cleaning of EventSpeakers Table ------

Select * from EventSpeakers;

Select * from EventSpeakers  where Eventid is null and speakerid is null and name is null ;  ---- No Null Data 

----- Deleting duplicates from EventSpeakers table 

with cte as(select *, ROW_NUMBER() over (partition by eventid,speakerid,name
							order by eventid) row_num from EventSpeakers)
							delete  from cte where row_num>1;


--- Removing Unwanted Columns(Wrong Columns) in EventSessions Table---------------

alter table EventSpeakers Drop column ContactURL,imageURL,imageHeight,imageWidth;

----- Updating blanks to NULL

Update EventSpeakers set twitter=null where speakerid in (select speakerid from EventSpeakers where twitter='');

Update EventSpeakers set linkedin=null where speakerid in (select speakerid from EventSpeakers where linkedin='');

Update EventSpeakers set [Description]=null where speakerid in (select speakerid from EventSpeakers where [description]='');



---------- Cleaning Data of EventSponsors Table

select * from EventSponsors;

delete from EventSponsors where  EventID is  null and sponsorid is  null and name is null;  --- Removing Null's Data from Table

with cte as(select *, ROW_NUMBER() over (partition by eventid,sponsorid,name
							order by eventid) row_num from EventSponsors)
							delete from cte where row_num>1;

alter table EventSponsors drop column imageurl,imageheight,imagewidth;

--------------- No need of Gender Maps Table, Dropping that table -----

drop table GenderMaps;

------------------------- Languages Table

select * from Languages;

with cte as(select *, ROW_NUMBER() over (partition by Languagecode,Language
							order by Languagecode) row_num from Languages)
							delete from cte where row_num>1;


--------- SessionsDownloads

select * from SessionsDownloads;

Select * from SessionsDownloads  where Eventid is null and sessionid is null and DownloadTitle is null;  ---- No Null Data 

----- Deleting duplicates from EventSessions table 

with cte as(select *, ROW_NUMBER() over (partition by eventid,sessionid,DownloadTitle
							order by eventid) row_num from SessionsDownloads)
							delete from cte where row_num>1;


----- SessionsSpeakers

select * from SessionsSpeakers;

with cte as(select *, ROW_NUMBER() over (partition by eventid,sessionid,speakerId
							order by eventid) row_num from SessionsSpeakers)
							delete from cte where row_num>1;
-------------------
select  * from events;

select top 10 right(state, len(state) - charindex((Substring(state,1,1)), state)) from events;

------ Removing unwanted , in starting of States 

update events set state= case 
		when substring(state,1,1)=','
		then LTRIM(REPLACE(state,',',''))
		else
		state
		end;

--------------------------------------------------------------------------------------------
------------------- Data Analysis ------------------

------------------ How many Events are conducted as part of this data ----------------

select distinct count(eventid) as NO_OF_EVENTS from events;

-------------------- For which event Highest no of attendee can attend ---------

select * from events where attendeeestimate 
in (select MAX(attendeeEstimate) from events) ;

------------------- For which Event highest no of sessions happened -------------------

with cte(eventid,Sessions_count) as (select e.eventid,count(es.sessionid) as Sessions_count from Events e 
join EventSessions es on e.eventid=es.eventid
group by e.eventid having count(es.sessionid)>1)
select top 1 ee.* from cte c join events ee on ee.eventid=c.eventid order by Sessions_count desc;


------------------ For which event most no of speakers used ----------------

with cte(eventid,Sessions_count) as (select e.eventid,count(es.SpeakerID) as Sessions_count from Events e 
join EventSpeakers es on e.eventid=es.eventid
group by e.eventid having count(es.SpeakerID)>1)
select top 1 ee.* from cte c join events ee on ee.eventid=c.eventid order by Sessions_count desc;

------------------- For which event more sponsors are there --------

with cte(eventid,Sessions_count) as (select e.eventid,count(es.SponsorID) as Sessions_count from Events e 
join EventSponsors es on e.eventid=es.eventid
group by e.eventid having count(es.SponsorID)>1)
select top 1 ee.* from cte c join events ee on ee.eventid=c.eventid order by Sessions_count desc;

--------------------- For which event max no of gold sponsors -----------

with cte as  (select eventid,case when [label] = 'Gold Sponsor' then
count([label]) 
end Count_Gold
from EventSponsors
group by EventID,[label])
select top 5 * from cte where Count_Gold is not null order by Count_Gold desc;

---------------- Creating Views -------------------

create view Events_Languages as 
select count(EventID) COUNT_OF_EVENTS ,EventID,es.LanguageCode,Language from EventSessions es 
join Languages l on l.LanguageCode=es.LanguageCode
group by EventID,es.LanguageCode,Language;

select * from Events_Languages;

---------------- Sub Query ----------------

select * from EventSessions where EventID in ( select EventID from SessionsDownloads)
and sessionid in ( select SessionID from SessionsDownloads)
