package gasm.core.utils.texture;

import buddy.BuddySuite;

using buddy.Should;

class TexturePackerImportTest extends BuddySuite {
    public function new() {
        describe("parse", {
            it("should return a valid spritesheet if provided valid json", {
                var sheetJson:TextureData = {
                    frames: {
                        "0.png": {
                            "frame": {
                                "x": 1,
                                "y": 1,
                                "w": 100,
                                "h": 140
                            },
                            "rotated": false,
                            "trimmed": false,
                            "spriteSourceSize": {
                                "x": 0,
                                "y": 0,
                                "w": 100,
                                "h": 140
                            },
                            "sourceSize": {
                                "w": 100,
                                "h": 140
                            },
                            "pivot": {
                                "x": 0.5,
                                "y": 0.5
                            }
                        }
                    },
                    meta: {
                        "app": "http://www.codeandweb.com/texturepacker",
                        "version": "1.0",
                        "image": "CARDS.png",
                        "format": "RGBA8888",
                        "size": {
                            "w": 1814,
                            "h": 426
                        },
                        "scale": "1",
                        "smartupdate": "$TexturePacker:SmartUpdate:f7228e659f09a1e1f4302b25a33f1608:56bbdd1249a1a5cc8691dca2dd61d6c6:0c259760b19e457668caa09afd5c317d$"
                    }
                }
                var result = TexturePackerImport.parse(sheetJson);
                result.frames[0].height.should.be(140);
            });
        });
    }
}
