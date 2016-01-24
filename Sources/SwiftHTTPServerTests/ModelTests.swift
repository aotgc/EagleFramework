/*
 * Copyright (C) 2015 Josh A. Beam
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Database

class ModelTests: TestCase {
    override var tests: TestDictionary {
        return [
            "testPropertyValues": {
                class TestModel: Model {
                    let boolProperty = Model.BoolProperty(defaultValue: false)
                    let doubleProperty = Model.DoubleProperty(defaultValue: 1.23)
                    let intProperty = Model.IntProperty(defaultValue: 42)
                    let stringProperty = Model.StringProperty(defaultValue: "Hello")

                    override init() {}
                }

                let model = TestModel()
                let propertyValues = model.propertyValues
                try assertEqual(propertyValues.count, 4)
                try assertEqual(propertyValues[0].name, "boolProperty")
                try assertEqual(propertyValues[0].value as? Bool, false)
                try assertEqual(propertyValues[1].value as? Double, 1.23)
                try assertEqual(propertyValues[1].name, "doubleProperty")
                try assertEqual(propertyValues[2].value as? Int64, 42)
                try assertEqual(propertyValues[2].name, "intProperty")
                try assertEqual(propertyValues[3].value as? String, "Hello")
                try assertEqual(propertyValues[3].name, "stringProperty")
            }
        ]
    }
}
