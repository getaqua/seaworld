abstract class Fragments {
  static const partialFlow = r"""fragment partialFlow on Flow {
    name
    description
    avatar_url
    id
    snowflake
  }""";
  /// Depends on [partialFlow] and [flowPermissions]
  static const fullFlow = r"""fragment fullFlow on Flow {
    ...partialFlow
    members {
      ...partialFlow
    }
    alternative_ids
    banner_url
    public_permissions {
      ...flowPermissions
    }
    joined_permissions {
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
      text
      author {
        name
        id
      }
    }
    pinned
    author {
      ...partialFlow
    }
    inFlowId
    timestamp
    # edited
    editedTimestamp
    snowflake
  }""";
  //static const name = r"""""";
}