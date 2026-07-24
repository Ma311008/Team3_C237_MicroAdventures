-- C237 CA2: Sample experiences seed (Singapore attractions & food)
-- Run AFTER schema.sql, against the same schema (e.g. C237_015_team3 on Azure).
-- created_by is resolved to the seeded admin account via a subquery so this
-- works regardless of the admin's auto-increment id.
--
-- NOTE: experiences has no UNIQUE constraint on title, so running this file
-- more than once will create duplicate rows. Run it ONCE.

USE C237_015_team3;

SET @admin := (SELECT id FROM users WHERE email = 'admin@adventure.com' LIMIT 1);

INSERT INTO experiences (title, description, category, location, difficulty, created_by) VALUES
-- ===== FOOD =====
('Tian Tian Hainanese Chicken Rice',
 'Join the legendary queue at Maxwell for a plate of silky, fragrant Hainanese chicken rice that even Anthony Bourdain swore by. Tender poached chicken sits atop rice cooked in rich chicken stock, finished with a fiery chilli-ginger dip. Simple, soulful, and unmistakably Singaporean.',
 'food', 'Maxwell Food Centre', 'easy', @admin),
('Chilli Crab at East Coast Seafood Centre',
 'Roll up your sleeves for Singapore''s messiest national treasure: mud crabs smothered in a sweet, savoury, subtly spicy tomato-chilli gravy. Mop up every last drop with pillowy fried mantou buns as the sea breeze drifts in off the East Coast. Come hungry and leave gloriously sticky.',
 'food', 'East Coast Seafood Centre', 'easy', @admin),
('328 Katong Laksa',
 'Slurp your way through a bowl of Katong laksa so iconic the noodles are snipped short enough to eat with just a spoon. Plump prawns and cockles swim in a coconut-rich, spicy gravy crowned with fragrant laksa leaf. A creamy, tingling bowl that defines the Peranakan east coast.',
 'food', 'East Coast Road, Katong', 'easy', @admin),
('Satay Street at Lau Pa Sat',
 'As night falls, Boon Tat Street closes to traffic and fills with smoky charcoal grills turning out skewer after skewer of caramelised satay. Dip chicken, mutton and beef into thick peanut sauce beside a stunning Victorian cast-iron market hall. The ultimate open-air supper in the heart of the CBD.',
 'food', 'Lau Pa Sat, Raffles Quay', 'easy', @admin),

-- ===== NATURE =====
('Gardens by the Bay Supertree Grove',
 'Wander beneath towering Supertrees that erupt into a dazzling light-and-sound show every evening. Stroll the elevated OCBC Skyway for sweeping views over the bay, then cool off inside the misty Cloud Forest dome. A futuristic garden that feels like stepping into tomorrow.',
 'nature', 'Gardens by the Bay', 'easy', @admin),
('MacRitchie TreeTop Walk',
 'Trek through lush rainforest to a 250-metre suspension bridge swaying high above the forest canopy. Keep your eyes peeled for long-tailed macaques, monitor lizards and flashes of tropical birdlife. A rewarding half-day hike that reveals the wild green heart hidden inside the city.',
 'nature', 'MacRitchie Reservoir', 'moderate', @admin),
('Henderson Waves & Southern Ridges',
 'Cross Singapore''s highest pedestrian bridge, a sculptural ribbon of wave-like timber arches that glows softly at dusk. The scenic Southern Ridges trail links hilltop parks with forest walkways and skyline panoramas. Golden hour here is pure magic.',
 'nature', 'Southern Ridges, Telok Blangah', 'moderate', @admin),
('Sungei Buloh Wetland Reserve',
 'Escape to mangrove boardwalks where mudskippers skitter, monitor lizards bask and migratory birds pause on their epic journeys. Quiet, wild and wonderfully unhurried, this coastal reserve is a birdwatcher''s paradise. Bring binoculars and let the tide reveal its secrets.',
 'nature', 'Sungei Buloh Wetland Reserve', 'easy', @admin),

-- ===== CULTURE =====
('Peranakan Katong Heritage Walk',
 'Wander streets lined with candy-coloured Peranakan shophouses adorned with intricate tiles and ornate facades. Discover the Straits-Chinese legacy of nyonya cuisine, beadwork and kebaya heritage around every corner. The most photogenic slice of old Singapore.',
 'culture', 'Joo Chiat & Katong', 'easy', @admin),
('Sri Mariamman Temple, Chinatown',
 'Step into Singapore''s oldest Hindu temple, where a riot of vividly painted deities crowns the towering gopuram gateway. Incense drifts through halls buzzing with ritual and colour in the unlikely heart of Chinatown. A vivid reminder of the island''s beautiful cultural mosaic.',
 'culture', 'South Bridge Road, Chinatown', 'easy', @admin),
('National Gallery Singapore',
 'Explore Southeast Asia''s largest collection of modern art inside two restored national monuments, the former Supreme Court and City Hall. Rooftop views, grand colonial architecture and thought-provoking galleries make it a cultural must. History and art collide beautifully under one iconic roof.',
 'culture', 'St Andrew''s Road, City Hall', 'easy', @admin),
('Kampong Glam & Sultan Mosque',
 'Gaze up at the golden dome of Sultan Mosque before losing yourself among textile shops, perfume traders and street art on Haji Lane. This historic Malay-Arab quarter hums with heritage cafes and buzzing character. Old-world charm meets creative cool.',
 'culture', 'Kampong Glam / Arab Street', 'easy', @admin),

-- ===== NIGHTLIFE =====
('CE LA VI Rooftop at Marina Bay Sands',
 'Sip cocktails 200 metres above the city on one of the world''s most jaw-dropping rooftops. Watch the skyline shimmer and the nightly light show ripple across the bay from your perch in the clouds. Dress sharp: this is Singapore glamour at its dizzying best.',
 'nightlife', 'Marina Bay Sands SkyPark', 'easy', @admin),
('Clarke Quay Riverside Night Out',
 'Neon-lit warehouses along the Singapore River pulse with bars, clubs and riverside dining until the early hours. Grab a drink, hop between live-music venues and watch bumboats glide past the glittering water. The city''s most electric after-dark playground.',
 'nightlife', 'Clarke Quay', 'easy', @admin),
('Ann Siang Hill Bar Hopping',
 'Duck into hidden speakeasies and stylish rooftop bars tucked inside restored shophouses on this leafy, lantern-lit hill. Craft cocktails, buzzing crowds and effortless cool define Singapore''s most beloved nightlife enclave. Come for one drink, stay for many.',
 'nightlife', 'Ann Siang Hill & Club Street', 'easy', @admin),

-- ===== SHOPPING =====
('Orchard Road Shopping Belt',
 'Stroll Singapore''s glittering shopping mile, a 2.2km ribbon of malls stretching from ION Orchard to Ngee Ann City. From luxury flagships to quirky basement finds, air-conditioned retail heaven never ends. Shop till you drop, then refuel at a food hall below.',
 'shopping', 'Orchard Road', 'easy', @admin),
('Bugis Street Market',
 'Dive into Singapore''s largest street market, a maze of stalls packed with fashion, trinkets, snacks and bargains galore. Haggle for accessories, sip bubble tea and soak up the youthful buzz. Cheap, cheerful and endlessly fun.',
 'shopping', 'Bugis Street', 'easy', @admin),
('Haji Lane Boutique Crawl',
 'Squeeze down Singapore''s hippest lane, where indie boutiques, vintage stores and mural-splashed walls set the scene. Discover one-of-a-kind fashion and homeware between cool cafes and rooftop bars. Small in size, big on personality.',
 'shopping', 'Haji Lane, Kampong Glam', 'easy', @admin),
('Mustafa Centre, Little India',
 'Lose yourself in this sprawling 24-hour emporium selling literally everything: electronics, gold, groceries, perfume and beyond. A chaotic, thrilling maze that never sleeps in the heart of Little India. Come at 3am just because you can.',
 'shopping', 'Syed Alwi Road, Little India', 'easy', @admin),

-- ===== CHALLENGING =====
('Bukit Timah Summit Trek',
 'Conquer Singapore''s highest hill on a steep, sweat-soaked trail winding through one of the world''s few urban primary rainforests. Scramble over exposed roots and rugged slopes as macaques watch from the canopy and cicadas roar around you. Reach the 164-metre summit marker and feel like you have earned every single step.',
 'nature', 'Bukit Timah Nature Reserve', 'challenging', @admin),
('Pulau Ubin Ketam Mountain Bike Trail',
 'Take a bumboat back in time to rustic Pulau Ubin, then tackle the island''s unforgiving Ketam Mountain Bike Park. Grind up punishing climbs, weave through technical rock gardens and fly down dusty descents built for serious riders. Raw, remote and gloriously old-school Singapore.',
 'nature', 'Pulau Ubin', 'challenging', @admin),
('Mala Xiang Guo Extreme Spice Challenge',
 'Pile your bowl high with lotus root, luncheon meat and greens, then dare the stall to crank the mala to maximum. Numbing Sichuan peppercorns and fiery chillies launch a slow-building inferno that separates the brave from the broken. Bring tissues, milk and a fearless tongue.',
 'food', 'Chinatown Food Street', 'challenging', @admin),
('One-Day Heritage Districts Marathon',
 'Traverse Singapore''s cultural soul on foot in a single epic day, from Chinatown''s temples to Little India''s garlands, Kampong Glam''s mosque and Katong''s Peranakan shophouses. It is kilometres of pavement, endless photo stops and joyful sensory overload from dawn to dusk. Comfortable shoes are non-negotiable.',
 'culture', 'Chinatown to Katong', 'challenging', @admin);
