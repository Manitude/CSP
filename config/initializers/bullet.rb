#if defined? Bullet && !RosettaStone::ProductionDetection.could_be_on_production?
#    Bullet.enable = true
#    #Bullet.console = true
#    Bullet.bullet_logger = true
#end
