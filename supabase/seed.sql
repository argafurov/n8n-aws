-- =========================================================
-- SAMPLE SEED DATA FOR n8n_ig SCHEMA
-- USERS, POSTS, COMMENTS, TAGGED USERS, COAUTHORS, MAPPINGS
-- =========================================================

-- ====================
-- USERS
-- ====================
insert into n8n_ig.users (
    id, username, full_name, profile_pic_url,
    posts_count, followers_count, follows_count,
    is_private, is_verified, is_business_account,
    biography, created_at, updated_at
) values
(1,
 'humansofny',
 'Humans of New York',
 'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-19/488057622_654626203990134_4938995104135839433_n.jpg',
 5835, 12836849, 657,
 false, true, false,
 'New York City, one story at a time. Created by Brandon Stanton. Dear New York now available wherever books are sold. Order below:',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(54488293283,
 'sure.ala',
 'о еде, маршрутах, людях.',
 'https://scontent-ord5-1.cdninstagram.com/v/t51.2885-19/456709348_509301708358297_3445541095337725010_n.jpg',
 0, 0, 0,
 false, true, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(77456654813,
 'wefryonfire',
 'Номинация WE FRY ON FIRE',
 'https://instagram.fagc3-1.fna.fbcdn.net/567982969_profile.jpg',
 0, 0, 0,
 false, false, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(69815504402,
 'metropolis.almaty',
 'Metropolis Almaty | медиа о городе',
 'https://instagram.fagc3-2.fna.fbcdn.net/573115267_profile.jpg',
 0, 0, 0,
 false, true, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(8947883,
 'syedin',
 'Andrey Syedin',
 'https://instagram.fagc3-2.fna.fbcdn.net/447770436_profile.jpg',
 0, 0, 0,
 false, true, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(17197569,
 'ruslan___zakirov',
 'Ruslan Zakirov',
 'https://instagram.fagc3-1.fna.fbcdn.net/418621699_profile.jpg',
 0, 0, 0,
 false, false, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(271550700,
 'svetacooks',
 'Svetlana Khaninaeva',
 'https://instagram.fagc3-2.fna.fbcdn.net/456968988_profile.jpg',
 0, 0, 0,
 false, false, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(73300685644,
 'teplo__almaty',
 'Тепло ☕️ Алматы',
 'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-19/485869525_profile.jpg',
 0, 0, 0,
 false, false, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(72922714537,
 'freedomtravelkz',
 'Freedom Travel (Aviata.kz)',
 'https://scontent-ord5-1.cdninstagram.com/v/t51.2885-19/491440205_profile.jpg',
 0, 0, 0,
 false, false, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(72521021416,
 'freedom_superapp',
 'Freedom SuperApp',
 'https://scontent-ord5-1.cdninstagram.com/v/t51.2885-19/480897385_profile.jpg',
 0, 0, 0,
 false, false, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(1502080350,
 'nikkipushka',
 '',
 'https://instagram.fagc3-2.fna.fbcdn.net/10691822_profile.jpg',
 0, 0, 0,
 false, false, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
),
(19628589,
 'sabikozh',
 '',
 'https://scontent-ord5-2.cdninstagram.com/v/t51.2885-19/485734018_profile.jpg',
 0, 0, 0,
 false, false, false,
 '',
 '2025-11-23T00:00:00Z', '2025-11-23T00:00:00Z'
);

-- ====================
-- POSTS (PARENTS)
-- ====================

insert into n8n_ig.posts (
  id,
  instagram_id,
  type,
  short_code,
  caption,
  hashtags,
  mentions,
  url,
  comments_count,
  first_comment,
  dimensions_height,
  dimensions_width,
  display_url,
  images,
  alt,
  likes_count,
  posted_at,
  location_name,
  location_id,
  owner_username,
  owner_instagram_id,
  owner_full_name,
  owner_user_id,
  is_comments_disabled,
  input_url,
  is_sponsored
) values
-- Post #1: WE FRY ON FIRE collab
(3766313806960904148,
 '3766313806960904148',
 'Sidecar',
 'DREonPgjcfU',
 'Пост о номинации WE FRY ON FIRE и стритфуде в Казахстане',
 array['друзья_шур'],
 array['wefryonfire'],
 'https://www.instagram.com/p/DREonPgjcfU/',
 2,
 '@dasdonerhaus я за вас 🔥',
 1350,
 1080,
 'https://instagram.fagc3-2.fna.fbcdn.net/v/t51.2885-15/581800447_18005821457821284_1946878469590219351_n.jpg',
 array[
   'https://instagram.fagc3-2.fna.fbcdn.net/v/t51.2885-15/581800447_18005821457821284_1946878469590219351_n.jpg',
   'https://instagram.fagc3-2.fna.fbcdn.net/v/t51.2885-15/582436030_18005821466821284_7179966916639234368_n.jpg',
   'https://instagram.fagc3-2.fna.fbcdn.net/v/t51.2885-15/582795371_18005821475821284_6378795335309266950_n.jpg'
 ],
 'Sample alt text for WE FRY ON FIRE post',
 169,
 '2025-11-15T09:40:14.000Z',
 'Almaty, Kazakhstan',
 '213264682',
 'sure.ala',
 '54488293283',
 'о еде, маршрутах, людях.',
 54488293283,
 false,
 'https://www.instagram.com/sure.ala/',
 false
),
-- Post #2: Freedom Travel collab
(3768366171863692367,
 '3768366171863692367',
 'Sidecar',
 'DRL7RFRiLRP',
 'Пост о распродаже путешествий с Freedom Travel и Freedom SuperApp',
 array['друзья_шур'],
 array['freedomtravelkz'],
 'https://www.instagram.com/p/DRL7RFRiLRP/',
 3,
 'Промокод действует на первую покупку или на все?',
 1350,
 1080,
 'https://scontent-ord5-3.cdninstagram.com/v/t51.2885-15/583817660_18006097157821284_8289723761027152492_n.jpg',
 array[
   'https://scontent-ord5-3.cdninstagram.com/v/t51.2885-15/583817660_18006097157821284_8289723761027152492_n.jpg',
   'https://scontent-ord5-3.cdninstagram.com/v/t51.2885-15/581718747_18006097169821284_603750144527469066_n.jpg',
   'https://scontent-ord5-3.cdninstagram.com/v/t51.2885-15/582106106_18006097178821284_4839515280445226784_n.jpg'
 ],
 'Sample alt text for Freedom Travel promo',
 171,
 '2025-11-18T05:37:55.000Z',
 null,
 null,
 'sure.ala',
 '54488293283',
 'о еде, маршрутах, людях.',
 54488293283,
 false,
 'https://www.instagram.com/sure.ala/',
 false
),
-- Post #3: Teplo Almaty review
(3764803569414119008,
 '3764803569414119008',
 'Sidecar',
 'DQ_ROZMDR5g',
 'Обзор кафе Тепло в Алматы, новое меню и уютная атмосфера',
 array['друзья_шур'],
 array['teplo__almaty'],
 'https://www.instagram.com/p/DQ_ROZMDR5g/',
 5,
 'Обожаю здесь завтраки 😍',
 1350,
 1080,
 'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-15/581897709_18005623880821284_2430182756170720364_n.jpg',
 array[
   'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-15/581897709_18005623880821284_2430182756170720364_n.jpg',
   'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-15/582604021_18005623889821284_5135958853289774503_n.jpg',
   'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-15/581231337_18005623898821284_7514510444006883121_n.jpg'
 ],
 'Sample alt text for Teplo Almaty review',
 218,
 '2025-11-13T07:39:40.000Z',
 null,
 null,
 'sure.ala',
 '54488293283',
 'о еде, маршрутах, людях.',
 54488293283,
 false,
 'https://www.instagram.com/sure.ala/',
 false
);

-- ====================
-- POSTS (CHILD SLIDES)
-- ====================

insert into n8n_ig.posts (
  id,
  instagram_id,
  type,
  short_code,
  caption,
  url,
  comments_count,
  dimensions_height,
  dimensions_width,
  display_url,
  images,
  likes_count,
  posted_at,
  owner_username,
  owner_instagram_id,
  owner_full_name,
  owner_user_id
) values
-- Child of Post #1 with tag @wefryonfire
(3766313798119291539,
 '3766313798119291539',
 'Image',
 'DREonHRjXqT',
 'Слайд с визуалом и тегом WE FRY ON FIRE',
 'https://www.instagram.com/p/DREonHRjXqT/',
 0,
 1350,
 1080,
 'https://instagram.fagc3-2.fna.fbcdn.net/v/t51.2885-15/581800447_18005821457821284_1946878469590219351_n.jpg',
 array[
   'https://instagram.fagc3-2.fna.fbcdn.net/v/t51.2885-15/581800447_18005821457821284_1946878469590219351_n.jpg'
 ],
 null,
 null,
 'sure.ala',
 '54488293283',
 'о еде, маршрутах, людях.',
 54488293283
),
-- Child of Post #1 with judges tags
(3766313798119297928,
 '3766313798119297928',
 'Image',
 'DREonHRjZOI',
 'Слайд с жюри номинации и тегами участников',
 'https://www.instagram.com/p/DREonHRjZOI/',
 0,
 1350,
 1080,
 'https://instagram.fagc3-2.fna.fbcdn.net/v/t51.2885-15/583251737_18005821484821284_1707050576481914544_n.jpg',
 array[
   'https://instagram.fagc3-2.fna.fbcdn.net/v/t51.2885-15/583251737_18005821484821284_1707050576481914544_n.jpg'
 ],
 null,
 null,
 'sure.ala',
 '54488293283',
 'о еде, маршрутах, людях.',
 54488293283
),
-- Child of Post #2 with Freedom tags
(3768366158097974312,
 '3768366158097974312',
 'Image',
 'DRL7Q4dCIQo',
 'Общий слайд распродажи с тегами Freedom SuperApp и Freedom Travel',
 'https://www.instagram.com/p/DRL7Q4dCIQo/',
 0,
 1350,
 1080,
 'https://scontent-ord5-3.cdninstagram.com/v/t51.2885-15/583817660_18006097157821284_8289723761027152492_n.jpg',
 array[
   'https://scontent-ord5-3.cdninstagram.com/v/t51.2885-15/583817660_18006097157821284_8289723761027152492_n.jpg'
 ],
 null,
 null,
 'sure.ala',
 '54488293283',
 'о еде, маршрутах, людях.',
 54488293283
),
-- Child of Post #3 with tag @teplo__almaty
(3764803555514234082,
 '3764803555514234082',
 'Image',
 'DQ_ROMPjbTi',
 'Первый слайд обзора Тепло с тегом аккаунта кафе',
 'https://www.instagram.com/p/DQ_ROMPjbTi/',
 0,
 1350,
 1080,
 'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-15/581897709_18005623880821284_2430182756170720364_n.jpg',
 array[
   'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-15/581897709_18005623880821284_2430182756170720364_n.jpg'
 ],
 null,
 null,
 'sure.ala',
 '54488293283',
 'о еде, маршрутах, людях.',
 54488293283
);

-- ====================
-- CHILD POST LINKS (post_child_posts)
-- ====================

insert into n8n_ig.post_child_posts (
  parent_post_id,
  child_post_id,
  position
) values
(3766313806960904148, 3766313798119291539, 1),
(3766313806960904148, 3766313798119297928, 2),
(3768366171863692367, 3768366158097974312, 1),
(3764803569414119008, 3764803555514234082, 1);

-- ====================
-- TAGGED USERS
-- ====================

insert into n8n_ig.tagged_users (
  id,
  instagram_id,
  username,
  full_name,
  profile_pic_url,
  is_verified,
  created_at,
  updated_at
) values
(77456654813,
 '77456654813',
 'wefryonfire',
 'Номинация WE FRY ON FIRE',
 'https://instagram.fagc3-1.fna.fbcdn.net/567982969_profile.jpg',
 false,
 '2025-11-23T00:00:00Z',
 '2025-11-23T00:00:00Z'
),
(8947883,
 '8947883',
 'syedin',
 'Andrey Syedin',
 'https://instagram.fagc3-2.fna.fbcdn.net/447770436_profile.jpg',
 true,
 '2025-11-23T00:00:00Z',
 '2025-11-23T00:00:00Z'
),
(69815504402,
 '69815504402',
 'metropolis.almaty',
 'Metropolis Almaty | медиа о городе',
 'https://instagram.fagc3-2.fna.fbcdn.net/573115267_profile.jpg',
 true,
 '2025-11-23T00:00:00Z',
 '2025-11-23T00:00:00Z'
),
(17197569,
 '17197569',
 'ruslan___zakirov',
 'Ruslan Zakirov',
 'https://instagram.fagc3-1.fna.fbcdn.net/418621699_profile.jpg',
 false,
 '2025-11-23T00:00:00Z',
 '2025-11-23T00:00:00Z'
),
(271550700,
 '271550700',
 'svetacooks',
 'Svetlana Khaninaeva',
 'https://instagram.fagc3-2.fna.fbcdn.net/456968988_profile.jpg',
 false,
 '2025-11-23T00:00:00Z',
 '2025-11-23T00:00:00Z'
),
(73300685644,
 '73300685644',
 'teplo__almaty',
 'Тепло ☕️ Алматы',
 'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-19/485869525_profile.jpg',
 false,
 '2025-11-23T00:00:00Z',
 '2025-11-23T00:00:00Z'
),
(72922714537,
 '72922714537',
 'freedomtravelkz',
 'Freedom Travel (Aviata.kz)',
 'https://scontent-ord5-1.cdninstagram.com/v/t51.2885-19/491440205_profile.jpg',
 false,
 '2025-11-23T00:00:00Z',
 '2025-11-23T00:00:00Z'
),
(72521021416,
 '72521021416',
 'freedom_superapp',
 'Freedom SuperApp',
 'https://scontent-ord5-1.cdninstagram.com/v/t51.2885-19/480897385_profile.jpg',
 false,
 '2025-11-23T00:00:00Z',
 '2025-11-23T00:00:00Z'
);

-- ====================
-- POST <-> TAGGED USERS (many-to-many)
-- ====================

insert into n8n_ig.post_tagged_users (
  post_id,
  tagged_user_id
) values
-- Root post #1 tagged users
(3766313806960904148, 8947883),       -- syedin
(3766313806960904148, 69815504402),   -- metropolis.almaty
(3766313806960904148, 17197569),      -- ruslan___zakirov
(3766313806960904148, 271550700),     -- svetacooks
(3766313806960904148, 77456654813),   -- wefryonfire
-- Child slide of post #1
(3766313798119291539, 77456654813),   -- wefryonfire
(3766313798119297928, 8947883),
(3766313798119297928, 69815504402),
(3766313798119297928, 17197569),
(3766313798119297928, 271550700),
-- Post #2 Freedom collab
(3768366171863692367, 72922714537),   -- freedomtravelkz
(3768366171863692367, 72521021416),   -- freedom_superapp
(3768366158097974312, 72922714537),
(3768366158097974312, 72521021416),
-- Post #3 Teplo
(3764803569414119008, 73300685644),
(3764803555514234082, 73300685644);

-- ====================
-- COAUTHOR PRODUCERS
-- ====================

insert into n8n_ig.coauthor_producers (
  id,
  instagram_id,
  username,
  profile_pic_url,
  is_verified,
  created_at,
  updated_at
) values
(77456654813,
 '77456654813',
 'wefryonfire',
 'https://instagram.fagc3-1.fna.fbcdn.net/567982969_profile.jpg',
 false,
 '2025-11-23T00:00:00Z',
 '2025-11-23T00:00:00Z'
);

-- Link main post to coauthor producer
insert into n8n_ig.post_coauthor_producers (
  post_id,
  coauthor_producer_id
) values
(3766313806960904148, 77456654813);

-- ====================
-- COMMENTS
-- ====================

insert into n8n_ig.comments (
  id,
  instagram_id,
  post_id,
  text,
  owner_username,
  owner_instagram_id,
  owner_profile_pic_url,
  likes_count,
  commented_at,
  replies_count
) values
-- Comments for Post #1
(18293346910285818,
 '18293346910285818',
 3766313806960904148,
 '@dasdonerhaus я за вас 🔥',
 'nikkipushka',
 '1502080350',
 'https://instagram.fagc3-2.fna.fbcdn.net/10691822_profile.jpg',
 1,
 '2025-11-18T06:26:46.000Z',
 0
),
(18076698250955581,
 '18076698250955581',
 3766313806960904148,
 '🔥❤️',
 'wefryonfire',
 '77456654813',
 'https://instagram.fagc3-1.fna.fbcdn.net/567982969_profile.jpg',
 1,
 '2025-11-15T13:24:28.000Z',
 0
),
-- Comments for Post #2
(17887758042265786,
 '17887758042265786',
 3768366171863692367,
 'Промокод действует на первую покупку или на все?',
 'sabikozh',
 '19628589',
 'https://scontent-ord5-2.cdninstagram.com/v/t51.2885-19/485734018_profile.jpg',
 0,
 '2025-11-18T07:55:06.000Z',
 0
),
(18100606039668781,
 '18100606039668781',
 3768366171863692367,
 '🔥🔥👏',
 'sayabayevaa',
 '5021185507',
 'https://scontent-ord5-2.cdninstagram.com/v/t51.2885-19/503327008_18331716406161508_747582414914678100_n.jpg',
 0,
 '2025-11-18T06:14:38.000Z',
 0
),
(18035019269722469,
 '18035019269722469',
 3768366171863692367,
 '@sabikozh на первую покупку с 19 по 21 ноября, старт в 00:00',
 'sure.ala',
 '54488293283',
 'https://scontent-ord5-1.cdninstagram.com/v/t51.2885-19/456709348_509301708358297_3445541095337725010_n.jpg',
 0,
 '2025-11-18T08:09:30.000Z',
 0
),
-- Comments for Post #3
(18078330422259391,
 '18078330422259391',
 3764803569414119008,
 'Обожаю здесь завтраки 😍',
 'rllna.vo',
 '2989716162',
 'https://scontent-iad3-2.cdninstagram.com/v/t51.2885-19/504646859_18414712420100163_7614048342835825170_n.jpg',
 0,
 '2025-11-14T10:51:48.000Z',
 0
),
(17858229597485942,
 '17858229597485942',
 3764803569414119008,
 'Беру тут хлеб домой. Тартин очень хороший и цена отличная',
 'whatever_n_name',
 '326358652',
 'https://scontent-iad3-1.cdninstagram.com/v/t51.2885-19/497808515_18503481784022653_8827368737075543815_n.jpg',
 0,
 '2025-11-13T11:20:20.000Z',
 0
),
(17956226865011026,
 '17956226865011026',
 3764803569414119008,
 'Место очень уютное, но кухня прям совсем не вкусная',
 'kraimer',
 '47260960',
 'https://scontent-iad3-1.cdninstagram.com/v/t51.2885-19/11849973_1466636593643373_13816522_a.jpg',
 1,
 '2025-11-13T11:05:40.000Z',
 0
);

-- ====================
-- LATEST COMMENTS MAPPING
-- ====================

insert into n8n_ig.post_latest_comments (
  post_id,
  comment_id,
  position
) values
-- For Post #1
(3766313806960904148, 18293346910285818, 1),
(3766313806960904148, 18076698250955581, 2),
-- For Post #2
(3768366171863692367, 17887758042265786, 1),
(3768366171863692367, 18100606039668781, 2),
(3768366171863692367, 18035019269722469, 3),
-- For Post #3
(3764803569414119008, 18078330422259391, 1),
(3764803569414119008, 17858229597485942, 2),
(3764803569414119008, 17956226865011026, 3);
