-- triggers depend on now() > '2018-MM-DD'
-- populate records that were created earlier on the next day using:
--
--   select * from count_all_requests(1000);
--   select * from count_all_commits(1000);
--   select * from count_all_branches(1000);
--   select * from count_all_pull_requests(1000);
--   select * from count_all_tags(1000);
--   select * from count_all_builds(1000);
--   select * from count_all_stages(1000);
--   select * from count_all_jobs(1000);

drop function if exists count_requests(_start int, _end int);
create or replace function count_requests(_start int, _end int)
returns table (repository_id int, owner_id int, owner_type varchar, requests bigint, range varchar) as $$
begin
  return query select t.repository_id, t.owner_id, t.owner_type, count(id) as requests, ('requests' || ':' || _start || ':' || _end)::varchar as range
  from requests as t
  where t.id between _start and _end and t.created_at < '2018-03-27 13:30:00' and t.repository_id is not null and t.owner_id is not null and t.owner_type is not null
  group by t.repository_id, t.owner_id, t.owner_type;
end;
$$
language plpgsql;

drop function if exists count_commits(_start int, _end int);
create or replace function count_commits(_start int, _end int)
returns table (repository_id int, owner_id int, owner_type varchar, commits bigint, range varchar) as $$
begin
  return query select r.id, r.owner_id, r.owner_type, count(t.id) as commits, ('commits' || ':' || _start || ':' || _end)::varchar as range
  from commits as t
  join repositories as r on t.repository_id = r.id
  where t.id between _start and _end and t.created_at < '2018-03-27 13:30:00' and t.repository_id is not null and r.owner_id is not null and r.owner_type is not null
  group by r.id, r.owner_id, r.owner_type;
end;
$$
language plpgsql;

drop function if exists count_branches(_start int, _end int);
create or replace function count_branches(_start int, _end int)
returns table (repository_id int, owner_id int, owner_type varchar, branches bigint, range varchar) as $$
begin
  return query select r.id, r.owner_id, r.owner_type, count(t.id) as branches, ('branches' || ':' || _start || ':' || _end)::varchar as range
  from branches as t
  join repositories as r on t.repository_id = r.id
  where t.id between _start and _end and t.created_at < '2018-03-27 13:30:00' and t.repository_id is not null and r.owner_id is not null and r.owner_type is not null
  group by r.id, r.owner_id, r.owner_type;
end;
$$
language plpgsql;

drop function if exists count_pull_requests(_start int, _end int);
create or replace function count_pull_requests(_start int, _end int)
returns table (repository_id int, owner_id int, owner_type varchar, pull_requests bigint, range varchar) as $$
begin
  return query select r.id, r.owner_id, r.owner_type, count(t.id) as pull_requests, ('pull_requests' || ':' || _start || ':' || _end)::varchar as range
  from pull_requests as t
  join repositories as r on t.repository_id = r.id
  where t.id between _start and _end and t.created_at < '2018-03-27 13:30:00' and t.repository_id is not null and r.owner_id is not null and r.owner_type is not null
  group by r.id, r.owner_id, r.owner_type;
end;
$$
language plpgsql;

drop function if exists count_tags(_start int, _end int);
create or replace function count_tags(_start int, _end int)
returns table (repository_id int, owner_id int, owner_type varchar, tags bigint, range varchar) as $$
begin
  return query select r.id, r.owner_id, r.owner_type, count(t.id) as tags, ('tags' || ':' || _start || ':' || _end)::varchar as range
  from tags as t
  join repositories as r on t.repository_id = r.id
  where t.id between _start and _end and t.created_at < '2018-03-27 13:30:00' and t.repository_id is not null and r.owner_id is not null and r.owner_type is not null
  group by r.id, r.owner_id, r.owner_type;
end;
$$
language plpgsql;

drop function if exists count_builds(_start int, _end int);
create or replace function count_builds(_start int, _end int)
returns table (repository_id int, owner_id int, owner_type varchar, builds bigint, range varchar) as $$
begin
  return query select t.repository_id, t.owner_id, t.owner_type, count(id) as builds, ('builds' || ':' || _start || ':' || _end)::varchar as range
  from builds as t
  where t.id between _start and _end and t.created_at < '2018-03-27 13:30:00' and t.repository_id is not null and t.owner_id is not null and t.owner_type is not null
  group by t.repository_id, t.owner_id, t.owner_type;
end;
$$
language plpgsql;

drop function if exists count_stages(_start int, _end int);
create or replace function count_stages(_start int, _end int)
returns table (repository_id int, owner_id int, owner_type varchar, stages bigint, range varchar) as $$
begin
  return query select b.repository_id, b.owner_id, b.owner_type, count(t.id) as stages, ('stages' || ':' || _start || ':' || _end)::varchar as range
  from stages as t
  join builds as b on t.build_id = b.id
  where t.id between _start and _end and b.created_at < '2018-03-27 13:30:00' and b.repository_id is not null and b.owner_id is not null and b.owner_type is not null
  group by b.repository_id, b.owner_id, b.owner_type;
end;
$$
language plpgsql;

drop function if exists count_jobs(_start int, _end int);
create or replace function count_jobs(_start int, _end int)
returns table (repository_id int, owner_id int, owner_type varchar, jobs bigint, range varchar) as $$
begin
  return query select t.repository_id, t.owner_id, t.owner_type, count(id) as jobs, ('jobs' || ':' || _start || ':' || _end)::varchar as range
  from jobs as t
  where t.id between _start and _end and t.created_at < '2018-03-27 13:30:00' and t.repository_id is not null and t.owner_id is not null and t.owner_type is not null
  group by t.repository_id, t.owner_id, t.owner_type;
end;
$$
language plpgsql;

drop function if exists count_all_requests(_count int);
create or replace function count_all_requests(_count int) returns boolean as $$
declare max int;
begin
  select id + _count from requests order by id desc limit 1 into max;

  for i in 0..coalesce(max, 1) by _count loop
    begin
      insert into repo_counts(repository_id, owner_id, owner_type, requests, range)
      select * from count_requests(i, i + _count);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$
language plpgsql;

drop function if exists count_all_commits(_count int);
create or replace function count_all_commits(_count int) returns boolean as $$
declare max int;
begin
  select id + _count from commits order by id desc limit 1 into max;

  for i in 0..coalesce(max, 1) by _count loop
    begin
      insert into repo_counts(repository_id, owner_id, owner_type, commits, range)
      select * from count_commits(i, i + _count);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$
language plpgsql;

drop function if exists count_all_branches(_count int);
create or replace function count_all_branches(_count int) returns boolean as $$
declare max int;
begin
  select id + _count from branches order by id desc limit 1 into max;

  for i in 0..coalesce(max, 1) by _count loop
    begin
      insert into repo_counts(repository_id, owner_id, owner_type, branches, range)
      select * from count_branches(i, i + _count);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$
language plpgsql;

drop function if exists count_all_pull_requests(_count int);
create or replace function count_all_pull_requests(_count int) returns boolean as $$
declare max int;
begin
  select id + _count from pull_requests order by id desc limit 1 into max;

  for i in 0..coalesce(max, 1) by _count loop
    begin
      insert into repo_counts(repository_id, owner_id, owner_type, pull_requests, range)
      select * from count_pull_requests(i, i + _count);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$
language plpgsql;

drop function if exists count_all_tags(_count int);
create or replace function count_all_tags(_count int) returns boolean as $$
declare max int;
begin
  select id + _count from tags order by id desc limit 1 into max;

  for i in 0..coalesce(max, 1) by _count loop
    begin
      insert into repo_counts(repository_id, owner_id, owner_type, tags, range)
      select * from count_tags(i, i + _count);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$
language plpgsql;

drop function if exists count_all_builds(_count int);
create or replace function count_all_builds(_count int) returns boolean as $$
declare max int;
begin
  select id + _count from builds order by id desc limit 1 into max;

  for i in 0..coalesce(max, 1) by _count loop
    begin
      insert into repo_counts(repository_id, owner_id, owner_type, builds, range)
      select * from count_builds(i, i + _count);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$
language plpgsql;

drop function if exists count_all_stages(_count int);
create or replace function count_all_stages(_count int) returns boolean as $$
declare max int;
begin
  select id + _count from stages order by id desc limit 1 into max;

  for i in 0..coalesce(max, 1) by _count loop
    begin
      insert into repo_counts(repository_id, owner_id, owner_type, stages, range)
      select * from count_stages(i, i + _count);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$
language plpgsql;

drop function if exists count_all_jobs(_count int);
create or replace function count_all_jobs(_count int) returns boolean as $$
declare max int;
begin
  select id + _count from jobs order by id desc limit 1 into max;

  for i in 0..coalesce(max, 1) by _count loop
    begin
      insert into repo_counts(repository_id, owner_id, owner_type, jobs, range)
      select * from count_jobs(i, i + _count);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$
language plpgsql;
