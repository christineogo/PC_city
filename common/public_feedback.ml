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
[@@deriving sexp, equal]



let defund_mandatory =
  [
    "Mandatory services? You mean optional at this point!";
    "Bro, the city running on DIY and community spirit fr(for real).";
    "Who is reaching my illegal function (party)? There is no 12 (police) to stop us!";
    "I waited three hours just for a band-aid. What’s up with that?";
    "The hospitals are so fugazi (bad), I hope no one gets sick"; 
    "The mandem(suspicious individuals) are outside again. I wish someone would stop them";
    "Bro the power is out AGAIN!";
    "Bro, my phone died AND the microwave’s off. I’m not built for this."; 
    "Not the nurse taking my pulse on FaceTime 💀";
    "My tap water is lowkey (kind of) a sus (odd) color..."; 
    "Why the water smell mad (very) weird?"; 
    "Tell me why I went to the hospital the other day and my volunteer doctor was vaping (smoking electronic cigarettes)! They need to fund these hospitals.."
  ]

let clean_power_pos =
  [ "I am so hype about clean energy. Who else loves the environment here?"; 
  "No more smoggy sunsets. We’re up!" 
  ;"PC City about to be the blueprint for eco-friendly living.";]

let clean_power_neg =
  [
    "This nuclear powerplant got me cheesed! What if it explodes?…time to \
     protest #NIMBY";
    "If I see one more documentary about green living I’m moving to the woods."
    ;"Why my electric bill looking THICKER now?!";

  ]

let high_occupancy =
  [
    "Why everyone moving to PC City? There are mad heads (many people) in my \
     apartment RN"; 
     "The elevator been stuck on ‘busy’ for an hour!"; 
     "Apartment’s so crowded, even the roaches need roommates."
     ; "The traffic is so crazy these days. Why do I have a 3 hour commute to work?"; 
     "I heard even New York has more space than this city does"; 


  ]

let high_tax =
  [ "These taxes have me feelin a certain type of way…might leave soon idk"
  ;"Just paid my taxes, gotta eat ramen for a week now."
  ; "If taxes go any higher, I’m starting an underground barter club."
  ; "Is PC City trying to turn me into a minimalist or what?";
  ]

(*if less than two plots of greenspacew*)
let greenspace_neg = [
  "I’d touch grass (go outside) but there’s only concrete out here 🥲"
  ;"The squirrels unionized and started charging rent for park benches.";
  "Finally found a patch of grass… and three people already picnicking on it." 
  ]

(*if more than 2 plots of greenspace*)
let greenspace_pos = [
  "Yo, who planted these flowers? PC City lookin’ kinda cute.";
  "Lowkey (kind of), these community gardens are saving my mental health.";
  ]

(*if business/apartments+houses > 1.2 *)
let high_business_ratio = [
  "Why are there more shops than people who actually live here??"
]

(*if business/apartments+houses < 0.8 *)
let low_business_ratio = [
  "So many people and not even one place to shop..."
]

(*if no grocery store *)
let no_grocery = [
  "This is literally a food desert..."; 
  "I NEED fresh fruit and vegatables. Please please can we have a grocery store."
]

let get_feedback_for_category category= 
  match category with 
  | Defund_mandatory -> defund_mandatory
  | Clean_power_pos ->clean_power_pos
  | Clean_power_neg -> clean_power_neg
  | High_occupancy -> high_occupancy
  | High_tax -> high_tax
  | Greenspace_pos -> greenspace_pos
  | Greenspace_neg -> greenspace_pos
  | High_business_ratio -> high_business_ratio
  | Low_business_ratio -> low_business_ratio
  | No_grocery -> no_grocery 
