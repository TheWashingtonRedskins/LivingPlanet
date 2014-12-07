Template.water.rendered = function(){
    $(document).ready(function (){
        console.log('bar');
        $(".water-expand").hide();
        // $(".water-expand").fadeIn(3000);
        $("#water-usa-expand").fadeIn(3000);
        $("#water-world-expand").fadeIn(5000);
        // $("#usa-1").fadeIn(2000);
        // $(".water-expand").animate({width:'toggle'},3000);

        $("#water-phone").hover(function(){$(this).animate({width:'7%'}, 500);},function(){$(this).animate({width:'5%'}, 500);});
        $("#water-toilet").hover(function(){$(this).animate({width:'13%'}, 500);},function(){$(this).animate({width:'10%'}, 500);});

    });
}