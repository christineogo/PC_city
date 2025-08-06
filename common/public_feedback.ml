type feedback_category =
  | Defund_mandatory
  | Clean_power_pos
  | Clean_power_neg
  | High_occupancy
  | High_tax
  | Greenspace_pos
  | Greenspace_neg
  | High_business_ratio
  | Low_business_ratio
  | No_grocery
  | No_schools
[@@deriving sexp, equal]

let defund_mandatory =
  [
    "Mandatory services? You mean optional at this point!";
    "Bro, with no mandatory services the city is running on DIY and community \
     spirit fr(for real).";
    "Who is reaching my illegal function (party)? There is no 12 (police) to \
     stop us!";
    "I waited three hours at hospital just for a band-aid. What’s up with that?";
    "The hospitals are so fugazi (bad), I hope no one gets sick";
    "The mandem(suspicious individuals) are outside again. I wish someone \
     would stop them";
    "Bro the power is out AGAIN!";
    "Bro, my phone died AND the microwave’s off. I’m not built for this.";
    "Not the nurse at the hospital taking my pulse on FaceTime 💀";
    "My tap water is lowkey (kind of) a sus (odd) color...";
    "Why the water smell mad (very) weird?";
    "Tell me why I went to the hospital the other day and my volunteer doctor \
     was vaping???";
  ]

let clean_power_pos =
  [
    "I am so hype about clean energy. Who else loves the environment here?";
    "No more smoggy sunsets. We’re up!";
    "PC City about to be the blueprint for eco-friendly living.";
    "Wind turbines? Solar panels? Say less.";
    "My lungs thank the mayor every morning.";
    "Clean energy is the vibe. I’m charging my phone with vibes now.";
    "I saw a kid plant a tree today. Hope for the future fr.";
    "The air here feels... crisp. Like sparkling water levels of clean.";
    "We’re so green I think we unlocked Earth 2.";
    "Eco-friendly and aesthetic? Go PC City!";
    "Green is the new black. PC City on that wave.";
  ]

let clean_power_neg =
  [
    "This nuclear powerplant got me cheesed! What if it explodes?";
    "If I see one more documentary about green living I’m moving to the woods.";
    "Why my electric bill looking THICKER now?!";
    "These solar panels are great... until it's cloudy for 3 days.";
    "I swear my lights flicker every time someone sneezes.";
    "The wind turbine's louder than my neighbor's lawn mower.";
    "Eco this, eco that — I just want reliable power.";
    "Charging my car takes longer than my commute!";
    "Did they power the city with vibes? Because my fridge just died.";
    "Where’s the sun when you need it?";
  ]

let high_occupancy =
  [
    "Why everyone moving to PC City? There are mad heads in my apartment RN";
    "The elevator been stuck on ‘busy’ for an hour!";
    "Apartment’s so crowded, even the roaches need roommates.";
    "The traffic is so crazy these days. Why do I have a 3 hour commute to \
     work?";
    "I heard even New York has more space than this city does";
    "I share a bathroom with 5 people. We’ve formed a line system.";
    "My neighbor’s couch is my new kitchen table.";
    "Y’all turning this place into SimCity nightmare mode.";
    "The buses are packed like sardines. I miss walking.";
    "I just saw someone sublet their closet 💀";
  ]

let high_tax =
  [
    "These taxes have me feelin a certain type of way…might leave soon idk";
    "Just paid my taxes, gotta eat ramen for a week now.";
    "If taxes go any higher, I’m starting an underground barter club.";
    "Is PC City trying to turn me into a minimalist or what?";
    "They taxed my cat's birthday party. Unbelievable.";
    "I sneezed and got charged a ‘pollen tax.’";
    "Y’all got a breathing surcharge too or nah?";
    "There’s a toll on my own driveway.";
    "I filed taxes and got a message that said ‘lol, good luck.’";
    "We’re paying city tax, air tax, and probably dream tax too.";
  ]

let greenspace_neg =
  [
    "I’d touch grass but there’s only concrete out here 🥲";
    "The squirrels unionized and started charging rent for park benches.";
    "Someone needs to tell the mayor about the urban heat island effect";
    "This city is literally just pavement. It is so hot and I am so unhappy \
     here.";
    "My kid just asked me 'what is a tree?'";
    "The birds fly over us and keep going.";
    "We got one tree and it's locked behind a fence.";
    "Sunburned my feet on the sidewalk. I was wearing shoes. Help.";
    "Even Google Maps says 'no parks nearby'.";
  ]

let greenspace_pos =
  [
    "Yo, who planted these flowers? PC City lookin’ kinda cute.";
    "Lowkey, these community gardens are saving my mental health.";
    "Going to the park makes me so happy! I hope PC City keeps adding \
     greenspace.";
    "The sun is out and everyone is at the park!";
    "I saw three dogs and a yoga class today. Elite experience.";
    "My apartment might be small, but the park is my second home.";
    "Green grass. Cool breeze. Yes, chef!";
    "Honestly? Nature be healing.";
    "I proposed in that new park. It’s that nice.";
    "Even the ducks seem happier.";
  ]

let high_business_ratio =
  [
    "Why are there more shops than people who actually live here??";
    "All these businesses and not a single place to live LOL";
    "I can get 14 kinds of coffee but can’t find an apartment.";
    "My barista offered to rent me the stockroom.";
    "Every block is just 'For Lease' signs.";
    "It's giving mall city. Where the people at?";
    "PC City: where stores outnumber residents 3 to 1.";
    "I saw a shop inside another shop. Inception?";
    "My address is a bakery. I don’t even work there.";
    "At this point, we’re a commercial— not a community.";
  ]

let low_business_ratio =
  [
    "All these people and there are like no stores? I had to wait in line to \
     get a toothbrush.";
    "Shopping in PC City is the worst! You have no options.";
    "No stores, no fun, no snacks. This is tragic.";
    "Even Amazon said 'we don’t deliver there.'";
    "You ever try to run errands and come back with nothing?";
    "We play 'Guess the open store' on weekends.";
    "The whole neighborhood shares one laundromat. It's war.";
    "This city runs on good intentions and empty shelves.";
  ]

let no_grocery =
  [
    "This is literally a food desert...";
    "I NEED fresh fruit and vegetables. Please please can we have a grocery \
     store.";
    "My groceries take 2 bus transfers and a prayer.";
    "I traded my last granola bar for toilet paper. We need a grocery store. \
     Times are tough.";
    "The vending machine is my new grocery aisle.";
    "I saw someone scalping apples out of a backpack. Fresh food is so hard to \
     find";
    "I miss vegetables. Tell broccoli I said hi.";
    "The nearest grocery store is a hike. With elevation.";
    "We have UberEats but nothing to order from.";
    "I dream about grocery aisles like it's Narnia.";
    "My pantry has ketchup, sadness, and hope.";
  ]

let no_schools =
  [
    "My kid thinks 'education' is a YouTube channel.";
    "No schools? We’re raising a generation of professional guessers.";
    "The closest school is in the next town over. By camel.";
    "I'm teaching my kids with cereal boxes and vibes.";
    "What do you mean we have no schools? This isn’t Lord of the Flies.";
    "My child just submitted a crayon drawing as a college app.";
    "Homework? Never heard of her.";
    "Kids be spelling 'cat' with a Q out here.";
    "We need education before this city turns into a group project gone wrong.";
  ]

let general = []

let get_feedback_for_category category =
  match category with
  | Defund_mandatory -> defund_mandatory
  | Clean_power_pos -> clean_power_pos
  | Clean_power_neg -> clean_power_neg
  | High_occupancy -> high_occupancy
  | High_tax -> high_tax
  | Greenspace_pos -> greenspace_pos
  | Greenspace_neg -> greenspace_neg
  | High_business_ratio -> high_business_ratio
  | Low_business_ratio -> low_business_ratio
  | No_grocery -> no_grocery
  | No_schools -> no_schools
  | General -> general
