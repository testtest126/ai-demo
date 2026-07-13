//
//  Core_AI_Language_Model_TestTests.swift
//  Core AI Language Model TestTests
//
//  Created by Y K on 06.07.26.
//

import Testing
import ArgumentParser
@testable import Core_AI_Language_Model_Test

struct Core_AI_Language_Model_TestTests {

    @Test func profileInstructionsChangeByMode() {
        let planner = AgentProfile.forMode(.planner)
        let reviewer = AgentProfile.forMode(.reviewer)
        let explainer = AgentProfile.forMode(.explainer)

        #expect(planner.instructions.contains("planning assistant"))
        #expect(reviewer.instructions.contains("reviewer"))
        #expect(explainer.instructions.contains("explainer"))
        #expect(planner.instructions != reviewer.instructions)
        #expect(planner.instructions != explainer.instructions)
    }

    @Test func argumentParserParsesStructuredAgentRequest() throws {
        let request = try AgentRequest.parse(["summarize", "--detail", "detailed", "--review"])

        #expect(request.task == "summarize")
        #expect(request.detail == .detailed)
        #expect(request.review)
    }

}
