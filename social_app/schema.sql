-- social_app Supabase Schema

-- ====================================================================================
-- 1. PROFILES
-- ====================================================================================
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  email text not null,
  avatar_url text,
  bio text,
  followers_count integer default 0,
  following_count integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.profiles enable row level security;

create policy "Public profiles are viewable by everyone."
  on public.profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on public.profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update their own profile."
  on public.profiles for update
  using ( auth.uid() = id );

-- ====================================================================================
-- 2. POSTS
-- ====================================================================================
create table public.posts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  caption text default '',
  media_url text not null,
  like_count integer default 0,
  comment_count integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.posts enable row level security;

create policy "Posts are viewable by everyone."
  on public.posts for select
  using ( true );

create policy "Users can create their own posts."
  on public.posts for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own posts."
  on public.posts for update
  using ( auth.uid() = user_id );
  
create policy "Users can delete their own posts."
  on public.posts for delete
  using ( auth.uid() = user_id );

-- Allow users to increment like_count
create policy "Anyone can update like_count"
  on public.posts for update
  using ( true ); 
  -- NOTE: In a real app we'd restrict this to just `like_count`, 
  -- but Supabase RLS update policies apply to the whole row. For MVP this is fine.

-- ====================================================================================
-- 3. COMMENTS
-- ====================================================================================
create table public.comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.comments enable row level security;

create policy "Comments are viewable by everyone."
  on public.comments for select
  using ( true );

create policy "Users can create their own comments."
  on public.comments for insert
  with check ( auth.uid() = user_id );

create policy "Users can delete their own comments."
  on public.comments for delete
  using ( auth.uid() = user_id );

-- Trigger to keep comment_count in sync
create or replace function public.update_comment_count()
returns trigger as $$
begin
  if (TG_OP = 'INSERT') then
    update public.posts set comment_count = comment_count + 1 where id = NEW.post_id;
    return NEW;
  elsif (TG_OP = 'DELETE') then
    update public.posts set comment_count = comment_count - 1 where id = OLD.post_id;
    return OLD;
  end if;
  return null;
end;
$$ language plpgsql security definer;

create trigger on_comment_added_or_removed
  after insert or delete on public.comments
  for each row execute function public.update_comment_count();

-- ====================================================================================
-- 4. CHAT
-- ====================================================================================
create table public.conversations (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.conversation_participants (
  conversation_id uuid references public.conversations(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  primary key (conversation_id, user_id)
);

create table public.messages (
  id uuid default gen_random_uuid() primary key,
  conversation_id uuid references public.conversations(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for chat tables
alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.messages enable row level security;

-- Policies
create policy "Users can see conversations they are part of"
  on public.conversations for select
  using ( auth.uid() in (select user_id from public.conversation_participants where conversation_id = id) );

create policy "Users can create conversations"
  on public.conversations for insert
  with check ( true );
  
create policy "Users can update conversations they are part of"
  on public.conversations for update
  using ( auth.uid() in (select user_id from public.conversation_participants where conversation_id = id) );

create policy "Users can see participants in their conversations"
  on public.conversation_participants for select
  using ( conversation_id in (select conversation_id from public.conversation_participants where user_id = auth.uid()) );

create policy "Users can add participants to conversations"
  on public.conversation_participants for insert
  with check ( true );

create policy "Users can see messages in their conversations"
  on public.messages for select
  using ( conversation_id in (select conversation_id from public.conversation_participants where user_id = auth.uid()) );

create policy "Users can send messages to their conversations"
  on public.messages for insert
  with check ( auth.uid() = sender_id and conversation_id in (select conversation_id from public.conversation_participants where user_id = auth.uid()) );
  
create policy "Users can update read status"
  on public.messages for update
  using ( conversation_id in (select conversation_id from public.conversation_participants where user_id = auth.uid()) );

-- Trigger to update conversation updated_at
create or replace function public.update_conversation_timestamp()
returns trigger as $$
begin
  update public.conversations set updated_at = now() where id = NEW.conversation_id;
  return NEW;
end;
$$ language plpgsql security definer;

create trigger on_message_added
  after insert on public.messages
  for each row execute function public.update_conversation_timestamp();


-- ====================================================================================
-- 5. AUTH TRIGGER (GMAIL RESTRICTION)
-- ====================================================================================
create or replace function public.handle_new_user()
returns trigger as $$
declare
  raw_username text;
begin
  -- Restrict signups to @gmail.com addresses only
  if new.email not like '%@gmail.com' then
    raise exception 'Signups are restricted to @gmail.com addresses only.';
  end if;

  -- Create a profile automatically
  -- Default username to part before @
  raw_username := split_part(new.email, '@', 1);

  insert into public.profiles (id, username, email, avatar_url, bio)
  values (
    new.id,
    raw_username,
    new.email,
    'https://ui-avatars.com/api/?name=' || raw_username || '&background=random',
    'Just joined!'
  );
  
  return new;
end;
$$ language plpgsql security definer;

-- Drop trigger if exists to avoid conflicts when re-running
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
