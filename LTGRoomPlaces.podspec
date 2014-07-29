Pod::Spec.new do |s|

    s.name              = 'LTGRoomPlaces'
    s.version           = '0.0.1'
    s.summary           = 'RoomPlaces API'
    s.homepage          = 'https://github.com/ltg-uic/ltg-room-places-cocoapod'
    s.license           = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author            = {
        'Paulo Guerr' => 'paulinhog84@gmail.com'
    }
    s.source            = {
        :git => 'https://github.com/ltg-uic/ltg-room-places-cocoapod.git'
    }
    s.source_files      = 'room-places-API/*.{h,swift}'
    s.requires_arc      = true

end