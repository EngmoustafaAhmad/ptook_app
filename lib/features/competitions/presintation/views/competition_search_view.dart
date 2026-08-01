import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';

import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/search_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/views/competition_details_view.dart';



class CompetitionSearchView extends StatefulWidget {

  const CompetitionSearchView({
    super.key,
  });


  @override
  State<CompetitionSearchView> createState() =>
      _CompetitionSearchViewState();

}




class _CompetitionSearchViewState
    extends State<CompetitionSearchView> {


  final controller = TextEditingController();



  @override
  void dispose() {

    controller.dispose();

    super.dispose();

  }





  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,


      appBar: AppBar(

        backgroundColor: AppColors.background,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),


        title: const Text(

          "Search Competitions",

          style: TextStyle(
            color: Colors.white,
          ),

        ),

      ),



      body: Padding(

        padding: const EdgeInsets.all(16),


        child: Column(

          children: [


            // Search Field
            TextField(

              controller: controller,


              autofocus: true,


              onChanged: (value){


                context
                    .read<SearchCompetitionCubit>()
                    .search(value);


              },



              style: const TextStyle(

                color: Colors.white,

              ),




              decoration: InputDecoration(


                hintText:
                "Search public competitions",



                hintStyle: TextStyle(

                  color:
                  Colors.white.withOpacity(.5),

                ),




                prefixIcon: const Icon(

                  Icons.search,

                  color: AppColors.primary,

                ),




                suffixIcon:
                controller.text.isNotEmpty

                    ? IconButton(

                  icon: const Icon(

                    Icons.clear,

                    color: Colors.white,

                  ),


                  onPressed: (){


                    controller.clear();


                    context
                        .read<SearchCompetitionCubit>()
                        .search("");

                    setState(() {});


                  },

                )

                    : null,






                filled: true,


                fillColor:
                AppColors.surface,




                border: OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(12),


                  borderSide:
                  BorderSide.none,

                ),

              ),

            ),





            20.vs,





            Expanded(

              child: BlocBuilder<
                  SearchCompetitionCubit,
                  SearchCompetitionState
              >(

                builder: (context,state){



                  // First open screen
                  if(state is SearchCompetitionInitial){

                    return _EmptySearch();


                  }






                  if(state is SearchCompetitionLoading){


                    return const Center(

                      child:
                      CircularProgressIndicator(

                        color:
                        AppColors.primary,

                      ),

                    );

                  }






                  if(state is SearchCompetitionError){


                    return Center(

                      child: Text(

                        state.message,


                        style:
                        const TextStyle(

                          color:
                          Colors.red,

                        ),

                      ),

                    );

                  }








                  if(state is SearchCompetitionSuccess){



                    if(state.competitions.isEmpty){


                      return Center(


                        child: Text(

                          "No competitions found",

                          style: TextStyle(

                            color:
                            Colors.white.withOpacity(.5),

                          ),

                        ),


                      );


                    }







                    return ListView.builder(


                      itemCount:
                      state.competitions.length,



                      itemBuilder:
                          (context,index){


                        return _CompetitionCard(

                          competition:
                          state.competitions[index],

                        );


                      },


                    );


                  }





                  return _EmptySearch();


                },

              ),

            )

          ],

        ),

      ),

    );

  }

}







class _EmptySearch extends StatelessWidget {


  @override
  Widget build(BuildContext context) {


    return Center(


      child: Column(


        mainAxisAlignment:
        MainAxisAlignment.center,



        children: [



          Icon(

            Icons.search,

            size: 70,

            color:
            Colors.white.withOpacity(.3),

          ),



          16.vs,



          Text(

            "Search for competitions",

            style: TextStyle(

              color:
              Colors.white.withOpacity(.5),

              fontSize: 16,

            ),

          ),


        ],


      ),

    );


  }

}









class _CompetitionCard extends StatelessWidget {


  final CompetitionEntity competition;



  const _CompetitionCard({

    required this.competition,

  });





  @override
  Widget build(BuildContext context) {



    final user =
        FirebaseAuth.instance.currentUser;



    final bool isOwner =
        user != null &&
        competition.ownerId == user.uid;





    return GestureDetector(


      onTap: (){


        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) =>
                CompetitionDetailsView(

                  competition:
                  competition,

                  isOwner:
                  isOwner,

                ),

          ),

        );


      },




      child: Container(


        margin:
        const EdgeInsets.only(

          bottom: 12,

        ),



        padding:
        const EdgeInsets.all(16),




        decoration: BoxDecoration(


          color:
          AppColors.surface,



          borderRadius:
          BorderRadius.circular(16),




          border: Border.all(

            color:
            AppColors.primary.withOpacity(.3),

          ),


        ),




        child: Column(


          crossAxisAlignment:
          CrossAxisAlignment.start,



          children: [



            Row(


              children: [



                const Icon(

                  Icons.emoji_events,

                  color:
                  AppColors.primary,

                ),



                10.hs,



                Expanded(


                  child: Text(


                    competition.name,


                    style:
                    const TextStyle(


                      color:
                      Colors.white,


                      fontSize:
                      18,


                      fontWeight:
                      FontWeight.bold,


                    ),


                  ),


                ),



              ],


            ),






            10.vs,






            Text(


              competition.description,


              maxLines:
              2,


              overflow:
              TextOverflow.ellipsis,



              style:
              TextStyle(

                color:
                Colors.white.withOpacity(.7),

              ),

            ),






            16.vs,






            Row(


              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,



              children: [



                Text(

                  competition.type == "team"

                      ? "👥 Teams"

                      : "👤 Individuals",


                  style:
                  const TextStyle(

                    color:
                    AppColors.primary,

                  ),

                ),






                ElevatedButton(


                  onPressed: (){


                    if(isOwner){


                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              CompetitionDetailsView(

                                competition:
                                competition,

                                isOwner:
                                true,

                              ),

                        ),

                      );


                    }

                    else{


                      // TODO:
                      // Join Competition Cubit


                    }


                  },




                  style:
                  ElevatedButton.styleFrom(


                    backgroundColor:
                    AppColors.primary,


                    foregroundColor:
                    AppColors.background,



                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(10),

                    ),

                  ),



                  child: Text(

                    isOwner
                        ? "Manage"
                        : "Join",

                  ),


                )

              ],


            )



          ],


        ),


      ),


    );


  }


}