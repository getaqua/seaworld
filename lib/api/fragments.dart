abstract class Fragments {
  static const partialFlow = r"""fragment partialFlow on Flow {
    name
    description
    avatarUrl
    bannerUrl
    id
    snowflake
    effectivePermissions {
      ...flowPermissions
    }
    isJoined
    isFollowing
  }""";
  /// Depends on [partialFlow] and [flowPermissions]
  static const fullFlow = r"""fragment fullFlow on Flow {
    ...partialFlow
    members {
      ...partialFlowMember
    }
    publicPermissions {
      ...flowPermissions
    }
    joinedPermissions {
      ...flowPermissions
    }
  }""";
  static const flowPermissions = r"""fragment flowPermissions on FlowPermissions {
    join
    view
    read
    post
    delete
    pin
    update
    anonymous
  }""";
  static const attachment = r"""fragment attachment on Attachment {
    url
    #downloadUrl
    mimeType
    #downloadMimeType
    filename
    yours
    snowflake
  }""";
  /// Depends on [attachment] and [partialFlow].
  static const content = r"""fragment content on Content {
    text
    attachments {
      ...attachment
    }
    origin { #TODO: PartialContent for this
      snowflake
    }
    pinned
    author {
      ...partialFlowMember
    }
    inFlowId
    timestamp
    # edited
    editedTimestamp
    snowflake
  }""";
  //static const name = r"""""";
  static const partialFlowMember = r"""fragment partialFlowMember on FlowMember {
    name
    avatarUrl
    member {
      ...partialFlow
    }
  }""";
}