open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

let component ~show ~on_close =
  let%arr show = show and on_close = on_close in
  if not show then Node.none
  else
    Node.div
      ~attrs:
        [ Attr.class_ "modal-overlay"; Attr.on_click (fun _ -> on_close ()) ]
      [
        Node.div
          ~attrs:
            [ Attr.class_ "modal"; Attr.on_click (fun _ -> Ui_effect.Ignore) ]
          [
            Node.h2 [ Node.text "PC City : An Interactive City Simulator Game" ];
            Node.h3 [ Node.text "Overview" ];
            Node.p
              [
                Node.text
                  "A city simulator, in which you are playing from birds-eye \
                   view to overlook a city grid. You are tasked with managing \
                   + building the city. You can add residences and businesses. \
                   You can also set tax rates to make money. The city will \
                   have a happiness score calculated on a number of factors, \
                   such as the ratio of businesses to residences, as well as \
                   the tax rate. Hover over different businesses and policies \
                   to see how they affect your city's happiness. Your goal is \
                   to make a profitable city, while also ensuring that your \
                   city is happy.";
              ];
            Node.h3 [ Node.text "Gameplay" ];
            Node.p
              [
                Node.text
                  "Your mayoral term will last 30 days. Here is an overview of \
                   the gameplay to ensure you are successful during your term.";
              ];
            Node.h4 [ Node.text "Overall Score:" ];
            Node.p
              [
                Node.text
                  "Calculated based on the amount and value of the buildings \
                   you have placed down during your term as mayor. Try your \
                   best to expand your city, while maintaining your city \
                   stats.";
              ];
            Node.h4 [ Node.text "Buying buildings:" ];
            Node.p
              [
                Node.text
                  "There are five mandatory buildings that you must place at \
                   the beginning of the game. The tutorial will instruct you \
                   to do so. They will be placed in order as shown in the city \
                   planner side bar.";
              ];
            Node.p
              [
                Node.text
                  "You can click on a grid block and then the city planner \
                   menu 'Buy' button to buy more buildings. Be sure to hover \
                   over each building type to learn more about the cost of the \
                   building and its effects on your population.";
              ];
            Node.h4 [ Node.text "Making Money:" ];
            Node.p
              [
                Node.text
                  "You can make money by placing down buildings that will \
                   bring in money. Hover over each building type in the city \
                   planner to learn more.";
              ];
            Node.p
              [
                Node.text
                  "You can also make money by taxing your citizens. Be sure to \
                   monitor your tax rate and public opinion to make sure your \
                   taxes are not too high!";
              ];
            Node.h4 [ Node.text "Public Opinion:" ];
            Node.p
              [
                Node.text
                  "Your public opinion tab is based entirely on your game \
                   state! You can monitor the public opinion to inform your \
                   decisions and find out what will make your people happy. It \
                   is important that you listen to the needs of your citizens.";
              ];
            Node.h4 [ Node.text "Policies" ];
            Node.p
              [
                Node.text
                  "Hover over each policy and learn about their effects before \
                   you enact them. Once you enact a policy you cannot un-enact \
                   it. Some policies are helpful for saving money, some will \
                   increase your happiness. ";
              ];
            Node.h4 [ Node.text "Unpredictable Behaviors:" ];
            Node.p
              [
                Node.text
                  "There is a chance that disasters can occur and affect your \
                   population. This can depend on the policies you have \
                   enacted. Clean energy might be very popular with your city, \
                   but could also be a policy that will cause protest. \
                   Defunding mandatory services could make your city \
                   vulnerable to fires. Some disasters might be completely out \
                   of your control. Be prepared for them and plan wisely!";
              ];
            Node.button
              ~attrs:
                [
                  Attr.class_ "modal-close";
                  Attr.on_click (fun _ -> on_close ());
                ]
              [ Node.text "Close" ];
          ];
      ]
